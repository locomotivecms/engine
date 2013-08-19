module Locomotive
  class SitePresenter < BasePresenter

    ## properties ##

    property    :name
    properties  :locales,       type: Array
    property    :timezone

    with_options if: Proc.new { Locomotive.config.multi_sites_or_manage_domains? } do |presenter|
      presenter.property  :subdomain
      presenter.property  :domains,   type: Array, required: false
    end

    with_options only_getter: true do |presenter|
      presenter.property :domains_without_subdomain, type: Array, if: Proc.new { Locomotive.config.multi_sites_or_manage_domains? }
      presenter.property :domain_name
      presenter.property :memberships, type: Array
    end

    properties  :seo_title, :meta_keywords, :meta_description, :robots_txt, required: false

    ## other getters / setters ##

    def domain_name
      Locomotive.config.domain
    end

    def timezone
      self.__source.timezone_name
    end

    def timezone=(timezone)
      self.__source.timezone_name = timezone
    end

    def memberships
      self.__source.memberships.map { |membership| membership.as_json(self.__options) }
    end

    ## custom as_json ##

    def as_json_for_html_view
      self.as_json(self.getters - %w(memberships))
    end

  end
end
