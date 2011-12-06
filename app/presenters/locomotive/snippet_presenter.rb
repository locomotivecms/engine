module Locomotive
  class SnippetPresenter < BasePresenter

    delegate :name, :slug, :template, :to => :source

    def updated_at
      I18n.l(self.source.updated_at, :format => :short)
    end

    def included_methods
      super + %w(name slug template updated_at)
    end

  end
end