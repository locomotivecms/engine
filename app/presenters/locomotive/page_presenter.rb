module Locomotive
  class PagePresenter < BasePresenter

    delegate :title, :slug, :fullpath, :seo_title, :meta_keywords, :meta_description, :handle, :raw_template, :published, :listed, :templatized, :templatized_from_parent, :target_klass_name, :redirect, :redirect_url, :template_changed, :cache_strategy, :response_type, :depth, :position, :to => :source

    delegate :title=, :slug=, :fullpath=, :seo_title=, :meta_keywords=, :meta_description=, :handle=, :raw_template=, :published=, :listed=, :templatized=, :templatized_from_parent=, :target_klass_name=, :redirect=, :redirect_url=, :cache_strategy=, :response_type=, :position=, :to => :source

    attr_writer :editable_elements

    def escaped_raw_template
      h(self.source.raw_template)
    end

    def editable_elements
      self.source.enabled_editable_elements.collect(&:as_json)
    end

    def set_editable_elements
      return unless @editable_elements

      # Need to parse to get the right editable elements first
      self.source.send(:_parse_and_serialize_template)

      @editable_elements.each do |editable_element_hash|
        slug = editable_element_hash['slug']
        block = editable_element_hash['block']

        block = nil if block && block.empty?

        el = self.source.find_editable_element(block, slug)
        el.to_presenter.assign_attributes(editable_element_hash) if el

        # FIXME: Not sure why we need to do this...
        if el.respond_to?(:source)
          self.source.save
          self.source.reload
          el = self.source.find_editable_element(block, slug)
          el.source = editable_element_hash['source']
        end
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
      super + %w(title slug fullpath handle seo_title meta_keywords meta_description raw_template published listed templatized templatized_from_parent target_klass_name redirect redirect_url cache_strategy response_type depth position template_changed editable_elements localized_fullpaths parent_fullpath)
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

  end
end
