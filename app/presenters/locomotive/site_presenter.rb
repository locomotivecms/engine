module Locomotive
  class SitePresenter < BasePresenter

    delegate :name, :subdomain, :domains, :robots_txt, :seo_title, :meta_keywords, :meta_description, :domains_without_subdomain, :to => :source

    def domain_name
      Locomotive.config.domain
    end

    def memberships
      self.source.memberships.map { |membership| membership.as_json(self.options) }
    end

    def included_methods
      super + %w(name domain_name subdomain domains robots_txt seo_title meta_keywords meta_description domains_without_subdomain memberships)
    end

  end
end