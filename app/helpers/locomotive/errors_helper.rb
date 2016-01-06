module Locomotive
  module ErrorsHelper

    def error_title
      @title || t(:title, scope: "locomotive.errors.#{action_name.gsub('error_', '')}")
    end

    def no_site_message_and_link
      options = Locomotive.config.host ? { host: Locomotive.config.host } : { only_path: true }

      if current_locomotive_account
        [no_site_message(:add_domain), sites_url(options)]
      else
        [no_site_message(:sign_in), sign_in_url(options)]
      end
    end

    def no_site_message(error_type)
      t(error_type, host: request.host, scope: 'locomotive.errors.no_site.message')
    end

  end
end
