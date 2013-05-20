module Locomotive
  class ContentFieldPresenter < BasePresenter

    ## properties ##

    properties  :name, :label, :type

    properties  :required, :localized, :unique, type: 'Boolean'

    properties  :hint, :position, required: false

    # text type field
    properties  :text_formatting, if: Proc.new { __source.type.to_s == 'text' }, description: 'text'

    # relationship type field
    with_options if: Proc.new { __source.is_relationship? }, description: 'belongs_to, has_many, many_to_many' do |presenter|
      presenter.properties  :class_name, :inverse_of, :order_by
      presenter.property    :ui_enabled, type: 'Boolean'
      presenter.property    :class_slug, only_getter: true
    end

    # select type field
    with_options if: Proc.new { __source.type.to_s == 'select' }, type: 'Array', description: 'select' do |presenter|
      presenter.property    :select_options,      only_getter: true
      presenter.property    :raw_select_options,  alias: :select_options
    end

    ## other getters / setters ##

    def raw_select_options
      self.__source.select_options.collect do |option|
        { id: option._id, name: option.name_translations, position: position }
      end
    end

    def raw_select_options=(values)
      values.each do |attributes|
        # translations ?
        if (name = attributes['name']).is_a?(Hash)
          translations = attributes['name_translations'] = attributes.delete('name')
          name = translations[self.site.default_locale]
        end

        option = self.__source.select_options.where(name: name).first
        option ||= self.__source.select_options.build

        option.attributes = attributes
      end
    end

    def class_slug
      self.content_type.class_name_to_content_type(self.__source.class_name).try(:slug) rescue ::Mongoid::Errors::DocumentNotFound
    end

    def class_name=(value)
      if value =~ /^Locomotive::ContentEntry/
        self.__source.class_name = value
      else
        if content_type = self.site.content_types.where(slug: value).first
          self.__source.class_name = content_type.entries_class_name
        end
      end
    end

    ## other methods ##

    def content_type
      self.__source.content_type
    end

    def site
      self.content_type.site
    end

  end
end