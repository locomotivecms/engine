module Locomotive
  class ContentEntryPresenter < BasePresenter

    delegate :_label, :_slug, :_position, :seo_title, :meta_keywords, :meta_description, :file_custom_fields, :has_many_custom_fields, :many_to_many_custom_fields, :to => :source

    SETTERS = %w{_position seo_title meta_keyworks meta_description}

    SETTERS.each do |setter|
      delegate :"#{setter}=", :to => :source
    end

    def self.create(content_type, params)
      filter_params(params, content_type)
      content_type.entries.create(params)
    end

    # Lists of all the attributes editable thru the html form for instance
    #
    # @returns [ List ] a list of attributes (string)
    #
    def safe_attributes
      self.source.custom_fields_safe_attributes + %w(_slug seo_title meta_keywords meta_description _destroy)
    end

    def filtered_custom_fields_methods
      self.source.custom_fields_methods do |rule|
        if self.source.is_a_custom_field_many_relationship?(rule['name'])
          # avoid circular dependencies, it should accept only one deep level
          self.depth == 0
        else
          true
        end
      end
    end

    def errors
      self.source.errors.to_hash.stringify_keys
    end

    def content_type_slug
      self.source.content_type.slug
    end

    def included_methods
      default_list = %w(_label _slug _position content_type_slug file_custom_fields has_many_custom_fields many_to_many_custom_fields safe_attributes)
      default_list << 'errors' if !!self.options[:include_errors]
      super + self.filtered_custom_fields_methods + default_list
    end

    def as_json(methods = nil)
      methods ||= self.included_methods
      {}.tap do |hash|
        methods.each do |meth|
          hash[meth]= (if self.source.custom_fields_methods.include?(meth.to_s)
            if self.source.is_a_custom_field_many_relationship?(meth.to_s)
              # go deeper
              self.source.send(meth).ordered.map { |entry| entry.to_presenter(:depth => self.depth + 1) }
            else
              self.source.send(meth) rescue nil
            end
          else
            self.send(meth.to_sym) rescue nil
          end)
        end
      end
    end

    protected

    def self.available_custom_field_names(content_type)
      content_type.entries_custom_fields.collect(&:name)
    end

    def available_custom_field_names
      self.class.available_custom_field_names(self.source.content_type)
    end

    def self.filter_params(params, content_type)
      params.each do |key, value|
        good_param = (SETTERS + self.available_custom_field_names(content_type)).include?(key.to_s)
        params.delete(key) unless good_param
      end
    end

    # Delegate custom field setters to source

    def respond_to?(meth)
      if meth.to_s =~ /^(.+)=$/
        custom_field_name = $1
        if available_custom_field_names.include?(custom_field_name)
          return true
        end
      end

      super
    end

    def method_missing(meth, *args, &block)
      # If the method is missing but we should respond to it, delegate it to the source
      if self.respond_to?(meth)
        self.source.send(meth, *args, &block)
      end
    end

  end
end
