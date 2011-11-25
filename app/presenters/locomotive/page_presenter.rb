module Locomotive
  class PagePresenter < BasePresenter

    delegate :title, :slug, :fullpath, :raw_template, :published, :template_changed, :cache_strategy, :to => :source

    def editable_elements
      self.source.enabled_editable_elements.collect(&:as_json)
    end

    def included_methods
      super + %w(title slug fullpath raw_template published published cache_strategy template_changed editable_elements)
    end

  end
end