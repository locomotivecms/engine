module Locomotive
  class SnippetPresenter < BasePresenter

    delegate :name, :slug, :template, :to => :source

    def included_methods
      super + %w(name slug template)
    end

  end
end