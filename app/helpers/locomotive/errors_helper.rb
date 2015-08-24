module Locomotive
  module ErrorsHelper

    def error_title
      @title || t(:title, scope: "locomotive.errors.#{action_name.gsub('error_', '')}")
    end

    def no_site_message_and_link
      options = Locomotive.config.host ? { host: Locomotive.config.host } : { only_path: true }

      if Locomotive::Account.count == 0
        [t('.message.create_account'), sign_up_url(options)]
      elsif current_locomotive_account
        [t('.message.add_domain', host: request.host), sites_url(options)]
      else
        [t('.message.sign_in', host: request.host), new_locomotive_account_session_url(options)]
      end
    end

  end
end
