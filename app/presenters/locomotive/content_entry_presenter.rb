module Locomotive
  class ContentEntryPresenter < BasePresenter

    delegate :_slug, :_position, :seo_title, :meta_keywords, :meta_description, :to => :source

    def custom_fields_methods
      source.custom_fields_recipe['rules'].map do |rule|
        case rule['type']
        when 'select' then [rule['name'], "#{rule['name']}_id"]
        when 'date'   then "formatted_#{rule['name']}"
        when 'file'   then "#{rule['name']}_url"
        else
          rule['name']
        end
      end.flatten
    end

    def safe_attributes
      source.custom_fields_recipe['rules'].map do |rule|
        case rule['type']
        when 'select' then "#{rule['name']}_id"
        when 'date'   then "formatted_#{rule['name']}"
        when 'file'   then [rule['name'], "remove_#{rule['name']}"]
        else
          rule['name']
        end
      end.flatten + %w(_slug seo_title meta_keywords meta_description)
    end

    def content_type_slug
      self.source.content_type.slug
    end

    def _file_fields
      self.source.custom_fields_recipe['rules'].find_all { |rule| rule['type'] == 'file' }.map { |rule| rule['name'] }
    end

    def included_methods
      super + self.custom_fields_methods + %w(_slug _position content_type_slug _file_fields safe_attributes persisted)
    end

    def method_missing(meth, *arguments, &block)
      if self.custom_fields_methods.include?(meth.to_s)
        self.source.send(meth) rescue nil
      else
        super
      end
    end

  end
end