module Locomotive
  class ContentEntryPresenter < BasePresenter

    delegate :_label, :_slug, :_position, :seo_title, :meta_keywords, :meta_description, :file_custom_fields, :has_many_custom_fields, :many_to_many_custom_fields, :to => :source

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

  end
end