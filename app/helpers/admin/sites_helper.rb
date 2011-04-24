module Admin::SitesHelper

  def application_domain
    domain = Locomotive.config.domain
    domain += ":#{request.port}" if request.port != 80
    domain
  end

  def error_on_domain(site, name)
    if (error = (site.errors[:domains] || []).detect { |n| n.include?(name) })
      content_tag(:span, error, :class => 'inline-errors')
    else
      ''
    end
  end

  def manage_subdomain_or_domains?
    Locomotive.config.manage_subdomain? || Locomotive.config.manage_domains?
  end

  def manage_subdomain?
    Locomotive.config.manage_subdomain?
  end

  def manage_domains?
    Locomotive.config.manage_domains?
  end

  def multi_sites?
    Locomotive.config.multi_sites?
  end

end
