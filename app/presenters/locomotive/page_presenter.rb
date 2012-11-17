module Locomotive
  class PagePresenter < BasePresenter

    delegate :title, :slug, :fullpath, :seo_title, :meta_keywords, :meta_description, :handle, :position, :raw_template, :published, :listed, :templatized, :templatized_from_parent, :target_klass_slug, :redirect, :redirect_url, :redirect_type, :template_changed, :cache_strategy, :response_type, :depth, :position, :translated_in, :to => :source

    delegate :title=, :slug=, :fullpath=, :seo_title=, :meta_keywords=, :meta_description=, :handle=, :raw_template=, :published=, :listed=, :templatized=, :templatized_from_parent=, :target_klass_name=, :redirect=, :redirect_url=, :response_type=, :cache_strategy=, :response_type=, :position=, :to => :source

    attr_writer :editable_elements

    def escaped_raw_template
      h(self.source.raw_template)
    end

    def editable_elements
      self.source.enabled_editable_elements.collect(&:as_json)
    end

    def set_editable_elements
      return unless @editable_elements

      self.source.force_serialize_template

      @editable_elements.each do |editable_element_hash|
        slug = editable_element_hash['slug']

        # Change empty string in block to nil
        if editable_element_hash['block'] && editable_element_hash['block'].blank?
          editable_element_hash['block'] = nil
        end
        block = editable_element_hash['block']

        el = self.fetch_editable_element(slug, block)
        el.try(:assign_attributes, editable_element_hash)
      end
    end

    def parent_fullpath
      self.source.parent.fullpath
    end

    def parent_fullpath=(parent_fullpath)
      current_site = self.source.site
      self.source.parent = current_site.pages.where(:fullpath => parent_fullpath).first
    end

    def target_entry_name=(target_entry_name)
      current_site = self.source.site
      self.source.target_klass_name = current_site.content_types.where(
        :slug => target_entry_name).first.klass_with_custom_fields(:entries).to_s
    end

    def included_methods
      super + %w(title slug fullpath handle seo_title meta_keywords meta_description position raw_template published listed templatized templatized_from_parent target_klass_slug redirect redirect_url redirect_type cache_strategy response_type depth position template_changed editable_elements localized_fullpaths translated_in)
    end

    def included_setters
      super + %w(title slug fullpath seo_title meta_keywords meta_description handle raw_template published listed templatized templatized_from_parent target_klass_name redirect redirect_url redirect_type cache_strategy response_type position editable_elements parent_fullpath target_entry_name)
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

    def save
      set_editable_elements
      super
    end

    protected

    def fetch_editable_element(slug, block)
      el = self.source.find_editable_element(block, slug)
      el.try(:to_presenter)
    end

  end
end
