module Locomotive
  class ContentEntryPresenter < BasePresenter

    delegate :_label, :_slug, :_position, :seo_title, :meta_keywords, :meta_description, :to => :source

    # Returns the value of a field in the context of the current entry.
    #
    # @params [ CustomFields::Field ] field The field
    #
    # @returns [ Object ] The value of the field for the entry
    #
    def value_for(field)
      getter = [*self.getters_for(field.name, field.type)].first.to_sym
      self.source.send(getter)
    end

    # Returns the list of getters for an entry
    #
    # @returns [ List ] a list of method names (string)
    #
    def custom_fields_methods
      self.source.custom_fields_recipe['rules'].map do |rule|
        self.getters_for rule['name'], rule['type']
      end.flatten
    end

    # Lists of all the attributes editable by a html form
    #
    # @returns [ List ] a list of attributes (string)
    #
    def safe_attributes
      self.source.custom_fields_recipe['rules'].map do |rule|
        case rule['type'].to_sym
        when :date                then "formatted_#{rule['name']}"
        when :file                then [rule['name'], "remove_#{rule['name']}"]
        when :select, :belongs_to then ["#{rule['name']}_id", "position_in_#{rule['name']}"]
        when :has_many            then nil
        else
          rule['name']
        end
      end.compact.flatten + %w(_slug seo_title meta_keywords meta_description _destroy)
    end

    def errors
      self.source.errors.to_hash.stringify_keys
    end

    def content_type_slug
      self.source.content_type.slug
    end

    def _file_fields
      self.source.custom_fields_recipe['rules'].find_all { |rule| rule['type'] == 'file' }.map { |rule| rule['name'] }
    end

    def _has_many_fields
      self.source.custom_fields_recipe['rules'].find_all { |rule| rule['type'] == 'has_many' }.map { |rule| [rule['name'], rule['inverse_of']] }
    end

    def included_methods
      default_list = %w(_label _slug _position content_type_slug _file_fields _has_many_fields safe_attributes)
      default_list << 'errors' if !!self.options[:include_errors]
      super + self.custom_fields_methods + default_list
    end

    def method_missing(meth, *arguments, &block)
      if self.custom_fields_methods.include?(meth.to_s)
        self.source.send(meth) rescue nil
      else
        super
      end
    end

    protected

    # Gets the names of the getter methods for a field.
    # The names depend on the field type.
    #
    # @params [ String ] name Name of the field
    # @params [ String ] type Type of the field
    #
    # @returns [ Object ] A string or an array of names
    def getters_for(name, type)
      case type.to_sym
      when :select      then [name, "#{name}_id"]
      when :date        then "formatted_#{name}"
      when :file        then "#{name}_url"
      when :belongs_to  then "#{name}_id"
      # when :has_many    then nil
      else
        name
      end
    end

  end
end