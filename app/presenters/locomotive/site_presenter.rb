module Locomotive
  class SitePresenter < BasePresenter

    ## properties ##

    properties  :name, :locales, :subdomain, :domains, :robots_txt
    properties  :seo_title, :meta_keywords, :meta_description, :domains_without_subdomain

    with_options :only_getter => true do |presenter|
      presenter.properties :domain_name, :memberships
    end

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
