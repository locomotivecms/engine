module Locomotive
  class SitePresenter < BasePresenter

    delegate :name, :subdomain, :domains, :robots_txt, :seo_title, :meta_keywords, :meta_description, :domains_without_subdomain, :to => :source

    def included_methods
      super + %w(name subdomain domains robots_txt seo_title meta_keywords meta_description domains_without_subdomain)
    end

  end
end