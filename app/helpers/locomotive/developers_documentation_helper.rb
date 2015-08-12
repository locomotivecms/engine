module Locomotive
  module DevelopersDocumentationHelper
    def developer_documentation_wagon_clone_string
       [ 'wagon clone',
         current_site_name_with_underscores,
         current_request_url,
         current_site_handle_parameter,
         current_locomotive_account_email_parameter,
         current_site_api_key_parameter].join(' ')
    end

    def current_site_name_with_underscores
      current_site.name.underscore.gsub(/(\W+)/, '_')
    end

    def current_request_url
      [request.scheme, '://', request.host_with_port].join
    end

    def current_site_handle_parameter
      ['-h', current_site.handle].join(' ')
    end

    def current_locomotive_account_email_parameter
      ['-e', current_locomotive_account.email].join(' ')
    end

    def current_site_api_key_parameter
      ['-a', current_locomotive_account.api_key].join(' ')
    end
  end
end
