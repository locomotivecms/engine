module Locomotive
  class SnippetPresenter < BasePresenter

    delegate :name, :slug, :template, :to => :source

    def updated_at
      I18n.l(self.source.updated_at, :format => :short)
    end

    def included_methods
      super + %w(name slug template updated_at)
    end

    def as_json_for_html_view
      methods = included_methods.clone - %w(template)
      self.as_json(methods)
    end

  end
end