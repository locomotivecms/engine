module Locomotive
  class PagePresenter < BasePresenter

    delegate :title, :slug, :fullpath, :raw_template, :published, :listed, :templatized, :redirect, :redirect_url, :template_changed, :cache_strategy, :to => :source

    def escaped_raw_template
      h(self.source.raw_template)
    end

    def editable_elements
      self.source.enabled_editable_elements.collect(&:as_json)
    end

    def included_methods
      super + %w(title slug fullpath raw_template published listed templatized redirect redirect_url cache_strategy template_changed editable_elements edit_url localized_fullpaths)
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