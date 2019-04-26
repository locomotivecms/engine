module Locomotive
  module Steam

    class APIEntrySubmissionService < EntrySubmissionService

      attr_accessor_initialize :service, :request

      def submit(type_slug, attributes = {})
        if load_content_type(type_slug)
          create_entry(attributes)
        else
          nil
        end
      end

      private

      def load_content_type(slug)
        @content_type = site.content_types.where(slug: slug, public_submission_enabled: true).first
      end

      def create_entry(attributes)
        ::Mongoid::Fields::I18n.with_locale(locale) do
          entry = engine_service.public_create(attributes, {
            ip_address:   self.request.ip,
            user_agent:   self.request.user_agent,
            referer:      self.request.referer,
            emails:       notified_emails
          })

          entity = entry.to_steam(@content_type)
          Locomotive::Steam::Decorators::I18nDecorator.new(entity, locale)
        end
      end

      def site
        self.request.env['locomotive.site']
      end

      def locale
        self.service.locale
      end

      # a public form might need to inform accounts from other Locomotive sites
      def notified_emails
        (
          self.request.params['notified_emails'] ||
          self.request.params['notified_accounts'] ||
          ''
        ).split(',')
      end

      def engine_service
        Locomotive::ContentEntryService.new(@content_type, nil, locale)
      end

    end

  end
end
