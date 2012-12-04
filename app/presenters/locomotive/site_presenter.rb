module Locomotive
  class SitePresenter < BasePresenter

    ## properties ##

    property    :name
    properties  :locales, type: Array
    property    :subdomain
    property    :domains, type: Array, required: false

    with_options only_getter: true do |presenter|
      presenter.property :domains_without_subdomain, type: Array
      presenter.property :domain_name
      presenter.property :memberships, type: Array
    end

    properties  :seo_title, :meta_keywords, :meta_description, :robots_txt, required: false

    ## other getters / setters ##

    def domain_name
      Locomotive.config.domain
    end

    def memberships
      self.source.memberships.map { |membership| membership.as_json(self.options) }
    end

    ## custom as_json ##

    def as_json_for_html_view
      self.as_json(self.getters - %w(memberships))
    end

  end
end
