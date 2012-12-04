module Locomotive
  class PagePresenter < BasePresenter

    ## properties / collections ##

    properties  :title, :slug, :handle, :position, :response_type, :cache_strategy, :raw_template
    properties  :seo_title, :meta_keywords, :meta_description
    properties  :published, :listed, :templatized, :templatized_from_parent
    properties  :redirect, :redirect_url, :redirect_type
    property    :target_klass_slug, :alias => [:target_klass_name, :target_entry_name]
    properties  :parent_fullpath, :parent_id, :only_setter => true

    with_options :only_getter => true do |presenter|
      presenter.properties :localized_fullpaths, :fullpath, :depth, :target_klass_slug, :template_changed, :translated_in, :escaped_raw_template
    end

    collection  :editable_elements

    ## other getters / setters ##

    def escaped_raw_template
      h(self.source.raw_template)
    end

    def localized_fullpaths
      {}.tap do |hash|
        self.site.locales.each do |locale|
          hash[locale] = self.site.localized_page_fullpath(self.source, locale)
        end
      end
    end

    def parent_fullpath=(fullpath)
      self.source.parent = self.site.pages.where(:fullpath => fullpath).first
    end

    def editable_elements=(elements)
      self.source.force_serialize_template # initialize the default editable_elements

      elements.each do |attributes|
        block, slug = attributes.delete(:block), attributes.delete(:slug)

        block = nil if block.blank? # change empty string in block to nil

        if element = self.source.find_editable_element(block, slug)
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
