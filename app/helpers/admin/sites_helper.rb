module Admin::SitesHelper
  
  def application_domain
    domain = Locomotive.config.default_domain
    domain += ":#{request.port}" if request.port != 80
    domain
  end
  
  def main_site_url(site = current_site, options = {})
    url = "http://#{site.subdomain}.#{Locomotive.config.default_domain}"
    url += ":#{request.port}" if request.port != 80    
    url = File.join(url, controller.request.fullpath) if options.has_key?(:uri) && options[:uri]
    url
  end
  
  def error_on_domain(site, name)
    if (error = (site.errors[:domains] || []).detect { |n| n.include?(name) })
      content_tag(:span, error, :class => 'inline-errors')
    else
      ''
    end
  end
  
end