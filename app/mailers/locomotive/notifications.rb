module Locomotive
  class Notifications < ActionMailer::Base

    default from: Locomotive.config.mailer_sender

    def new_content_entry(account, entry)
      @account, @entry, @type = account, entry, entry.content_type

      if Locomotive.config.multi_sites_or_manage_domains?
        @domain = entry.site.domains.first
      else
        @domain = ActionMailer::Base.default_url_options[:host] || 'localhost'
      end

      subject = t('locomotive.notifications.new_content_entry.subject', domain: @domain, type: @type.name, locale: account.locale)

      mail subject: subject, to: account.email
    end
  end

end