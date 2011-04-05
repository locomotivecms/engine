module Admin::SitesHelper

  def application_domain
    domain = Locomotive.config.domain
    domain += ":#{request.port}" if request.port != 80
    domain
  end

  def main_site_url(site = current_site, options = {})
    # TODO: to be refactored
    if multi_sites?
      url = "http://#{site.subdomain}.#{Locomotive.config.domain}"
      url += ":#{request.port}" if request.port != 80
    else
      url = "#{request.protocol}#{request.host_with_port}"
    end
    url = File.join(url, request.fullpath) if options.has_key?(:uri) && options[:uri]
    url
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
