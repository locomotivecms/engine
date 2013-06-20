module Locomotive
  class ContentEntryPresenter < BasePresenter

    ## properties ##

    properties  :_label, only_getter: true

    property    :_slug

    properties  :_position, :_visible, required: false

    properties  :seo_title, :meta_keywords, :meta_description, required: false

    with_options only_getter: true do |presenter|
      presenter.properties  :content_type_slug, :translated_in

      presenter.property    :errors, if: Proc.new { include_errors? }
    end

    with_options only_getter: true, if: Proc.new { html_view? } do |presenter|
      presenter.properties  :safe_attributes
      presenter.properties  :select_custom_fields, :file_custom_fields, :belongs_to_custom_fields, :has_many_custom_fields, :many_to_many_custom_fields
    end

    ## callbacks ##

    set_callback :set_attributes, :after, :set_dynamic_attributes

    ## other getters / setters ##

    def errors
      super
    end

    def content_type_slug
      self.__source.content_type.slug
    end

    def safe_attributes
      self.__source.custom_fields_safe_setters + %w(_slug _visible seo_title meta_keywords meta_description)
    end

    ## other methods ##

    def as_json_with_custom_fields
      as_json_without_custom_fields.merge(self.custom_fields_to_hash)
    end

    alias_method_chain :as_json, :custom_fields

    def as_json_for_html_view
      self.__options[:html_view] = true
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
      base = self.__source.custom_fields_basic_attributes
      base.merge!(self.many_relationships_to_hash)
      base.merge!(self.belongs_to_to_hash)
    end

    # Build the hash storing for each *belongs_to* type field the target entry.
    #
    # @return [ Hash ] The hash whose name is the name of the belongs_to field
    #
    def belongs_to_to_hash
      {}.tap do |hash|
        self.__source.belongs_to_custom_fields.each do |name, _|
          if target = self.__source.send(name.to_sym)
            if self.html_view?
              hash["#{name}_id"] = target._id
            else
              hash[name.to_s]    = target._slug
            end
          end
        end
      end
    end

    # Build the hash storing for each *many* type field
    # the list of entries.
    #
    # @return [ Hash ] The hash whose name is the name of the relationhip
    #
    def many_relationships_to_hash
      {}.tap do |hash|
        (self.__source.has_many_custom_fields + self.__source.many_to_many_custom_fields).each do |name, _|
          if self.__depth == 0
            list = self.__source.send(name.to_sym).ordered
            hash[name.to_s] = list.map do |entry|
              if self.html_view?
                entry.to_presenter(depth: self.__depth + 1, html_view: true).as_json
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
    def set_dynamic_attributes
      # process the basic types
      self.__source.custom_fields_basic_attributes = @_attributes

      # now the relationships
      self.__source.relationship_custom_fields.each do |rule|
        if rule['type'] == 'belongs_to'
          self.set_belongs_to_attribute(rule['name'], rule['class_name'])
        elsif rule['type'] == 'many_to_many'
          self.set_many_to_many_attribute(rule['name'], rule['class_name'])
        end
      end
    end

    def set_belongs_to_attribute(name, class_name)
      id_or_slug  = @_attributes[name] || @_attributes["#{name}_id"]

      return if id_or_slug.nil?

      entry = self.fetch_content_entries(class_name, id_or_slug).first

      if entry
        self.__source.send(:"#{name}_id=", entry._id)

        if position = @_attributes["#{name}_position"]
          self.__source.send(:"#{name}_position=", position)
        end
      end
    end

    def set_many_to_many_attribute(name, class_name)
      ids_or_slugs  = @_attributes[name] || @_attributes["#{name}_ids"]

      return if ids_or_slugs.nil?

      entries = self.fetch_content_entries(class_name, ids_or_slugs)

      unless entries.empty?
        entries = entries.sort do |a, b|
          (ids_or_slugs.index(a._id.to_s) || ids_or_slugs.index(a._permalink)) <=>
          (ids_or_slugs.index(b._id.to_s) || ids_or_slugs.index(b._permalink))
        end # keep the original order

        self.__source.send(:"#{name}=", entries.to_a)
      end
    end

    # Return all the ids of the content entries matching the ids or the slugs
    #
    # @param [ Array ] ids_or_slugs Array of ids or slugs
    #
    # @return [ Array ] The matching entries
    #
    def fetch_content_entries(class_name, ids_or_slugs)
      ids_or_slugs  = [*ids_or_slugs]
      klass         = class_name.constantize

      klass.any_of({ :_slug.in => ids_or_slugs }, { :_id.in => ids_or_slugs })
    end

  end
end
