module Locomotive
  class SnippetPresenter < BasePresenter

    ## properties ##

    properties  :name, :slug, :template
    property    :updated_at, only_getter: true

    ## other getters / setters ##

    def updated_at
      I18n.l(self.__source.updated_at, format: :short)
    end

    ## custom as_json ##

    def as_json_for_html_view
      self.as_json(self.getters - %w(template))
    end

  end
end
