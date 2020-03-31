require 'adomain'

module Locomotive
  class Notifications < ActionMailer::Base

    SMTP_SETTINGS_NAMES = %w(smtp_settings mailer_settings email_settings).freeze
    SMTP_ATTRIBUTES = %w(address authentication port enable_starttls_auto user_name password domain).freeze

    after_action :set_delivery_options

    def new_content_entry(site, account, entry)
      @site, @account = site, account
      @entry, @type   = entry, entry.content_type
      @domain         = fetch_domain

      subject = new_content_entry_subject(entry, domain: @domain, type: @type.name, locale: account.locale)
      from    = fetch_from

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

    def site_mailer_settings
      SMTP_SETTINGS_NAMES
      .map { |namespace| @site.cast_metafields(namespace) }
      .compact.first || {}
    end

    def fetch_domain
      @site.domains.first || ActionMailer::Base.default_url_options[:host] || 'localhost'
    end

    def fetch_from
      if from = site_mailer_settings['from']
        from
      elsif top_level_domain = Adomain.domain(@domain)
        "noreply@#{top_level_domain}"
      else
        Locomotive.config.mailer_sender
      end
    end

    def set_delivery_options
      smtp_settings = site_mailer_settings.slice(*SMTP_ATTRIBUTES).delete_if { |_, value| value.blank? }.symbolize_keys

      if smtp_settings && smtp_settings[:address].present?
        mail.delivery_method.settings = smtp_settings
      end
    end

  end
end
