module Locomotive
  class PagePresenter < BasePresenter

    ## properties / collections ##

    properties  :title, :slug

    property    :parent_id

    property    :parent_fullpath, only_setter: true

    property    :position, type: 'Integer'

    properties  :handle, :response_type, :cache_strategy

    property    :redirect, type: 'Boolean'
    properties  :redirect_url, :redirect_type

    properties  :listed, :published, :templatized, type: 'Boolean'

    property    :templatized_from_parent, type: 'Boolean', only_getter: true
    property    :target_klass_slug, alias: [:target_klass_name, :target_entry_name]

    with_options only_getter: true do |presenter|
      presenter.property :fullpath
      presenter.property :localized_fullpaths,  type: 'Hash'
      presenter.property :depth,                type: 'Integer'
      presenter.property :template_changed,     type: 'Boolean'
      presenter.property :translated_in,        type: 'Array'
    end

    property    :raw_template
    property    :escaped_raw_template, only_getter: true

    collection  :editable_elements, presenter: EditableElementPresenter

    properties  :seo_title, :meta_keywords, :meta_description, required: false

    ## other getters / setters ##

    def escaped_raw_template
      h(self.__source.raw_template)
    end

    def localized_fullpaths
      {}.tap do |hash|
        self.site.locales.each do |locale|
          hash[locale] = self.site.localized_page_fullpath(self.__source, locale)
        end
      end
    end

    def parent_fullpath=(fullpath)
      self.__source.parent = self.site.pages.where(fullpath: fullpath).first
    end

    def editable_elements
      self.__source.enabled_editable_elements.map(&:as_json)
    end

    def editable_elements=(elements)
      self.__source.force_serialize_template # initialize the default editable_elements

      elements.each do |attributes|
        block, slug = attributes.delete(:block), attributes.delete(:slug)

        block = nil if block.blank? # change empty string in block to nil

        if element = self.__source.find_editable_element(block, slug)
          element.from_presenter(attributes)
        end
      end
    end

    ## custom as_json ##

    def as_json_for_html_view
      self.as_json(self.getters - %w(raw_template))
    end

  end
end
