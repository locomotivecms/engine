require 'adomain'

module Locomotive
  class Notifications < ActionMailer::Base

    def new_content_entry(account, entry)
      @site, @account = entry.site, account
      @entry, @type   = entry, entry.content_type

      @domain = entry.site.domains.first ||
        ActionMailer::Base.default_url_options[:host] ||
        'localhost'

      subject = new_content_entry_subject(entry, domain: @domain, type: @type.name, locale: account.locale)
      from    = (if top_level_domain = Adomain.domain(@domain)
         "noreply@#{top_level_domain}"
      else
        Locomotive.config.mailer_sender
      end)

      # attach uploaded files
      if @type.public_submission_email_attachments
        entry.file_custom_fields.each do |name|
          next if (file = entry.send(name)&.file).nil?
          attachments[file.filename] = file.read
        end
      end

      mail subject: subject, from: from, to: account.email, reply_to: from
    end

    protected

    def new_content_entry_subject(entry, options)
      if entry.content_type.public_submission_title_template.blank?
        t('locomotive.notifications.new_content_entry.subject', options)
      else
        entry.content_type.public_submission_title(entry, options)
      end
    end

  end
end
