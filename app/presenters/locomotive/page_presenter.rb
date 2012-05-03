module Locomotive
  class PagePresenter < BasePresenter

    delegate :title, :slug, :fullpath, :handle, :raw_template, :published, :listed, :templatized, :templatized_from_parent, :redirect, :redirect_url, :template_changed, :cache_strategy, :response_type, :to => :source

    delegate :title=, :slug=, :fullpath=, :handle=, :raw_template=, :published=, :listed=, :templatized=, :templatized_from_parent=, :redirect=, :redirect_url=, :cache_strategy=, :response_type=, :to => :source

    def escaped_raw_template
      h(self.source.raw_template)
    end

    def editable_elements
      self.source.enabled_editable_elements.collect(&:as_json)
    end

    def editable_elements=(editable_elements)
      editable_elements.each do |editable_element_hash|
        editable_element_id = editable_element_hash[:id]
        editable_element_type = editable_element_hash[:type]
        if editable_element_id
          editable_element_hash.delete(:id)
          editable_element_hash.delete(:_id)
          editable_element = self.source.editable_elements.find(editable_element_id)
        else
          editable_element = "Locomotive::#{editable_element_type}".constantize.new
          editable_element.page = self.source
        end

        editable_element_presenter = editable_element.to_presenter
        editable_element_presenter.update_attributes(editable_element_hash)
      end
    end

    def parent_fullpath
      self.source.parent.fullpath
    end

    def parent_fullpath=(parent_fullpath)
      self.source.parent = Page.where(:fullpath => parent_fullpath).first
    end

    def included_methods
      super + %w(title slug fullpath handle raw_template published listed templatized templatized_from_parent redirect redirect_url cache_strategy response_type template_changed editable_elements localized_fullpaths parent)
    end

    def localized_fullpaths
      site = self.source.site

      {}.tap do |hash|
        site.locales.each do |locale|
          hash[locale] = site.localized_page_fullpath(self.source, locale)
        end
      end
    end

    def as_json_for_html_view
      methods = included_methods.clone - %w(raw_template)
      self.as_json(methods)
    end

  end
end
