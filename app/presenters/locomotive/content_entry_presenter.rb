module Locomotive
  class ContentEntryPresenter < BasePresenter

    ## properties ##

    properties  :_label, only_getter: true

    property    :_slug

    property    :_position, required: false

    properties  :seo_title, :meta_keywords, :meta_description, required: false

    with_options only_getter: true do |presenter|
      presenter.properties  :content_type_slug, :translated_in

      presenter.property    :errors, if: Proc.new { !!options[:include_errors] }
    end

    with_options only_getter: true, if: Proc.new { html_view? } do |presenter|
      presenter.properties  :file_custom_fields, :has_many_custom_fields, :many_to_many_custom_fields
    end

    ## callbacks ##

    set_callback :set_attributes, :after, :set_dynamic_attributes

    ## other getters / setters ##

    def content_type_slug
      self.source.content_type.slug
    end

    ## other methods ##

    def as_json_with_custom_fields
      as_json_without_custom_fields.merge(self.custom_fields_to_hash)
    end

    alias_method_chain :as_json, :custom_fields

    def as_json_for_html_view
      self.options[:html_view] = true
      as_json_without_custom_fields.merge(self.custom_fields_to_hash)
    end

    protected

    # Build the hash representing the values of all
    # the custom fields of the content entry.
    # It also includes the ones from relationships fields
    #
    # @return [ Hash ] key the name of the custom field and value from the source
    #
    def custom_fields_to_hash
      {}.tap do |hash|
        self.source.custom_fields_safe_attributes.each do |name|
          hash[name] = self.source.send(name.to_sym)
        end
      end.merge(self.many_relationships_to_hash).merge(self.belongs_to_to_hash)
    end

    # Build the hash storing for each *belongs_to* type field the target entry.
    #
    # @return [ Hash ] The hash whose name is the name of the belongs_to field
    #
    def belongs_to_to_hash
      {}.tap do |hash|
        self.source.belongs_to_custom_fields.each do |name, _|
          if self.depth == 0
            hash[name.to_s] = self.source.send(name.to_sym).try(:_slug)
          end
        end
      end
    end

    # Build the hash storing for each *many* type field
    # the list of entries.
    #
    # @param [ Hash] options Some options passed to modify the output
    #
    # @return [ Hash ] The hash whose name is the name of the relationhip
    #
    def many_relationships_to_hash(options = {})
      {}.tap do |hash|
        (self.source.has_many_custom_fields + self.many_to_many_custom_fields).each do |name, _|
          if self.depth == 0
            list = self.source.send(name.to_sym).ordered
            hash[name.to_s] = list.map do |entry|
              if self.html_view?
                entry.to_presenter(depth: self.depth + 1).as_json
              else
                entry._slug
              end
            end
          end
        end
      end
    end

    # Set the values of the dynamic attributes for the
    # content entry instance. This method is called automatically
    # (callback) when the attributes= is called.
    #
    #
    def set_dynamic_attributes
      self.source.custom_fields_recipe['rules'].each do |rule|
        case rule['type'].to_sym
        when :string, :text, :boolean
          set_basic_attribute(rule['name'])
        when :date
          set_date_attribute(rule['name'])
        when :file
          set_file_attribute(rule['name'])
        when :select
          set_select_attribute(rule['name'])
        when :belongs_to
          set_belongs_to_attribute(rule['name'], rule['class_name'])
        when :has_many
          # do nothing
        when :many_to_many
          set_many_to_many_attribute(rule['name'], rule['class_name'])
        end
      end
    end

    def set_basic_attribute(name, &block)
      return if (value = @_attributes[name]).nil?
      value = block.call(value) if block_given?
      self.source.send(:"#{name}=", value)
    end

    def set_date_attribute(name)
      @_attributes["formatted_#{name}"] = @_attributes.delete(name) if @_attributes[name]
      set_basic_attribute("formatted_#{name}")
       #{ |value| formatted_time(value) }

      # [name, "formatted_#{name}"].each do |_name|
      #   set_basic_attribute(_name) #{ |value| formatted_time(value) }
      # end

      # formatted_date_or_not = @_attributes[name] || @_attributes["formatted_#{name}"]
      # return unless formatted_date_or_not
      # value = formatted_time(formatted_date_or_not)
      # self.source.created_at = value

      # return unless @_attributes.key?("formatted_#{name}")
      # value = formatted_time(@_attributes["formatted_#{name}"])
      # self.source.send(:"#{name}=", value) if value
    end

    def set_file_attribute(name)
      [name, "remove_#{name}"].each do |_name|
        self.set_basic_attribute(_name)
      end
    end

    def set_select_attribute(name)
      id_or_name  = @_attributes[name] || @_attributes["#{name}_id"]

      return if id_or_name.nil?

      options = self.source.class._select_options(name)

      option = options.detect { |option| [option['_id'], option['name']].include?(id_or_name) }

      self.source.send(:"#{name}_id=", option['_id'])
    end

    def set_belongs_to_attribute(name, class_name)
      id_or_slug  = @_attributes[name] || @_attributes["#{name}_id"]

      return if id_or_slug.nil?

      puts "#{name} = #{id_or_slug}"

      entry = self.fetch_content_entries(class_name, id_or_slug).first

      if entry
        self.source.send(:"#{name}_id=", entry._id)

        # position
        if position = @_attributes["#{name}_position"]
          self.set_basic_attribute("#{name}_position")
        end
      end
    end

    def set_many_to_many_attribute(name, class_name)
      ids_or_slugs  = @_attributes[name] || @_attributes["#{name}_ids"]

      return if ids_or_slugs.nil?

      entries = self.fetch_content_entries(class_name, ids_or_slugs)

      unless entries.empty?
        self.source.send(:"#{name}=", entries)
      end
    end

    # Return all the ids of the content entries matching the ids or the slugs
    #
    # @param [ Array ] ids_or_slugs Array of ids or slugs
    #
    # @return [ Array ] ids of the matching entries
    #
    def fetch_content_entries(class_name, ids_or_slugs)
      ids_or_slugs  = [*ids_or_slugs]
      klass         = class_name.constantize

      # selector = klass.any_of({ :_slug.in => ids_or_slugs }, { :_id.in => ids_or_slugs }).selector
      # cursor   = klass.collection.find(selector, fields: { _id: 1 }).cursor

      # cursor.to_a.map { |hash| klass.new(_id: hash['_id']) }.tap { |o| puts o.inspect }

      # tmp = .only(:_id)
      # puts tmp.inspect
      # puts tmp.all.inspect
      # tmp

      klass.any_of({ :_slug.in => ids_or_slugs }, { :_id.in => ids_or_slugs })
    end

    # delegate  :_label, :_slug, :_position, :translated_in, :seo_title,
    #           :meta_keywords, :meta_description, :select_custom_fields,
    #           :file_custom_fields, :has_many_custom_fields, :many_to_many_custom_fields, to: :source

    # delegate :_slug=, :_position=, :seo_title=, :meta_keywords=, :meta_description=, to: :source

    # attr_accessor :objects_to_save

    # # Lists of all the attributes editable thru the html form for instance
    # #
    # # @returns [ List ] a list of attributes (string)
    # #
    # def safe_attributes
    #   self.source.custom_fields_safe_attributes + %w(_slug seo_title meta_keywords meta_description _destroy)
    # end

    # def filtered_custom_fields_methods
    #   self.source.custom_fields_methods do |rule|
    #     if self.source.is_a_custom_field_many_relationship?(rule['name'])
    #       # avoid circular dependencies, it should accept only one deep level
    #       self.depth == 0
    #     else
    #       true
    #     end
    #   end
    # end

    # def additional_custom_fields_methods
    #   [].tap do |methods|
    #     self.source.custom_fields_recipe['rules'].each do |rule|
    #       if rule['type'] == 'belongs_to'
    #         methods << "position_in_#{rule['name'].underscore}"
    #       end
    #     end
    #   end
    # end

    # def formatted_created_at=(created_at)
    #   self.source.timeless
    #   self.source.created_at = formatted_time(created_at)
    # end

    # def formatted_updated_at=(updated_at)
    #   self.source.timeless
    #   self.source.updated_at = formatted_time(updated_at)
    # end

    # def errors
    #   self.source.errors.to_hash.stringify_keys
    # end

    # def content_type_slug
    #   self.source.content_type.slug
    # end

    # def included_methods
    #   default_list = %w(_label _slug _position seo_title meta_keywords meta_description content_type_slug select_custom_fields file_custom_fields has_many_custom_fields many_to_many_custom_fields translated_in safe_attributes)
    #   default_list << 'errors' if !!self.options[:include_errors]
    #   super + self.filtered_custom_fields_methods + self.additional_custom_fields_methods + default_list
    # end

    # def included_setters
    #   super + %w(_slug _position seo_title meta_keywords meta_description formatted_created_at formatted_updated_at) + self.available_custom_field_names
    # end

    # def as_json(methods = nil)
    #   methods ||= self.included_methods
    #   {}.tap do |hash|
    #     methods.each do |meth|
    #       hash[meth]= (if self.source.custom_fields_methods.include?(meth.to_s) \
    #                    || self.additional_custom_fields_methods.include?(meth.to_s)
    #         if self.source.is_a_custom_field_many_relationship?(meth.to_s)
    #           # go deeper
    #           self.source.send(meth).ordered.map { |entry| entry.to_presenter(depth: self.depth + 1) }
    #         else
    #           self.source.send(meth) rescue nil
    #         end
    #       else
    #         self.send(meth.to_sym) rescue nil
    #       end)
    #     end
    #   end
    # end

    # protected

    # # Mimic format used by to_json
    # def formatted_time(time_str)
    #   format = '%Y-%m-%dT%H:%M:%S%Z'
    #   ::Time.strptime(time_str, format)
    # end

    # def available_custom_field_names
    #   return @available_custom_field_names if @available_custom_field_names

    #   # Find all "file" and "belongs_to" fields
    #   file_fields = Set.new
    #   belongs_to_fields = Set.new
    #   self.source.content_type.entries_custom_fields.each do |f|
    #     name = f.name
    #     file_fields << name if f.type == 'file'
    #     belongs_to_fields << name if f.type == 'belongs_to'
    #   end

    #   # Replace file field urls and belongs_to IDs with the actual field names
    #   @available_custom_field_names = self.source.custom_fields_methods.collect do |name|
    #     if name =~ /^(.+)_url$/ && file_fields.include?($1)
    #       name.sub(/_url$/, '')
    #     elsif name =~ /^(.+)_id$/ && belongs_to_fields.include?($1)
    #       name.sub(/_id$/, '')
    #     else
    #       name
    #     end
    #   end

    #   @available_custom_field_names
    # end

    # # Deal with "many" and "belongs_to" relationships

    # def get_custom_field_name_for_method(meth)
    #   if meth.to_s =~ /^(.+)=$/
    #     meth = $1
    #   end
    #   meth
    # end

    # def custom_field_for_method(meth)
    #   name = get_custom_field_name_for_method(meth)
    #   self.source.content_type.entries_custom_fields.where(name: name).first
    # end

    # def get_target_klass_for_custom_field_method(meth)
    #   field = custom_field_for_method(meth)
    #   field.class_name.constantize
    # end

    # def get_many_field_objects(meth, slug_list)
    #   target_klass = get_target_klass_for_custom_field_method(meth)
    #   # FIXME: too many DB accesses
    #   slug_list.collect { |slug| target_klass.where(_slug: slug).first }
    # end

    # def get_belongs_field_object(meth, slug)
    #   target_klass = get_target_klass_for_custom_field_method(meth)
    #   target_klass.where(_slug: slug).first
    # end

    # def is_has_many_custom_field?(meth)
    #   field = custom_field_for_method(meth)
    #   field && field.type == 'has_many'
    # end

    # def is_many_custom_field?(meth)
    #   field = custom_field_for_method(meth)
    #   field && %w{has_many many_to_many}.include?(field.type)
    # end

    # def is_belongs_to_custom_field?(meth)
    #   field = custom_field_for_method(meth)
    #   field && field.type == 'belongs_to'
    # end

    # def set_positions_for_has_many(objs, meth)
    #   field = get_custom_field_name_for_method(meth)
    #   objs.each_with_index do |obj, index|
    #     inverse_field ||= (self.source.custom_fields_recipe['rules'].detect do |rule|
    #       rule['name'] == field
    #     end)['inverse_of']

    #     if inverse_field
    #       obj.send(:"position_in_#{inverse_field}=", index)
    #     end
    #   end
    # end

    # def save
    #   objects_to_save.each { |obj| obj.save } if objects_to_save
    #   super
    # end

    # # Delegate custom field setters to source

    # def method_missing(meth, *args, &block)
    #   # If the setter is missing but it's in the available_custom_field_names, delegate it to the source
    #   field_name = get_custom_field_name_for_method(meth)
    #   if self.available_custom_field_names.include?(field_name)
    #     # If it's a "many" or "belong_to" field, pass in the right objects
    #     if is_many_custom_field?(field_name)
    #       new_args = args.collect { |list| get_many_field_objects(field_name, list) }

    #       # Get the objects which we need to save
    #       self.objects_to_save ||= []
    #       self.objects_to_save += new_args.flatten

    #       # If it's a has_many field, set the positions
    #       if is_has_many_custom_field?(field_name)
    #         self.set_positions_for_has_many(new_args.flatten, field_name)
    #       end

    #       self.source.send(meth, *new_args, &block)
    #     elsif is_belongs_to_custom_field?(field_name)
    #       new_args = args.collect { |slug| get_belongs_field_object(meth, slug) }
    #       self.source.send(meth, *new_args, &block)
    #     else
    #       self.source.send(meth, *args, &block)
    #     end
    #   else
    #     super
    #   end
    # end

  end
end
