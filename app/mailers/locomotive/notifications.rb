module Locomotive
  class Notifications < ActionMailer::Base

    SMTP_SETTINGS_NAMES = %w(smtp_settings mailer_settings email_settings).freeze
    SMTP_ATTRIBUTES = %w(address authentication port enable_starttls_auto user_name password domain).freeze

    after_action :configure_delivery

    def new_content_entry(site, account, entry)
      @site, @account = site, account
      @entry, @type   = entry, entry.content_type
      @domain         = fetch_domain

      subject = new_content_entry_subject(entry, domain: @domain, type: @type.name, locale: account.locale)

      # attach uploaded files
      if @type.public_submission_email_attachments
        entry.file_custom_fields.each do |name|
          next if (file = entry.send(name)&.file).nil?
          attachments[file.filename] = file.read
        end
      end

      mail subject: subject, to: account.email
    end

    protected

    def new_content_entry_subject(entry, options)
      if entry.content_type.public_submission_title_template.blank?
        t('locomotive.notifications.new_content_entry.subject', **options)
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

    def configure_delivery
      settings      = site_mailer_settings
      smtp_settings = settings.slice(*SMTP_ATTRIBUTES).delete_if { |_, value| value.blank? }.symbolize_keys
      site_from     = settings['from']

      if smtp_settings[:address].present?
        if site_from.blank?
          skip_delivery('site SMTP settings without a from address')
        elsif !valid_site_sender?(site_from)
          skip_delivery('invalid site from address')
        else
          mail.delivery_method(:smtp, smtp_settings)
          set_sender(site_from)
        end
      elsif Locomotive.config.allow_site_notifications_via_application_delivery_method
        set_sender(Locomotive.config.mailer_sender)
      else
        skip_delivery('no site SMTP settings')
      end
    end

    def set_sender(address)
      mail.from     = address
      mail.reply_to = address
    end

    def skip_delivery(reason)
      mail.perform_deliveries = false
      Locomotive::Common::Logger.warn(
        "[Notifications] skipped for site #{@site._id} (#{action_name}): #{reason}".yellow
      )
    end

    def valid_site_sender?(value)
      address = Mail::Address.new(value.to_s)
      address.address.present? && address.domain.present?
    rescue Mail::Field::ParseError
      false
    end

  end
end
