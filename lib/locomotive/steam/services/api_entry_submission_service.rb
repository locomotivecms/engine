module Locomotive
  module Steam

    class APIEntrySubmissionService < Struct.new(:site, :locale, :ip_address)

      def submit(slug, attributes = {})
        if load_content_type(slug)
          create_entry(attributes)
        else
          nil
        end
      end

      def find(type_slug, slug)
        if entry = load_content_type(type_slug).entries.where(_slug: slug).first
          make_entity(entry)
        end
      end

      def to_json(entry)
        make_entity(entry).to_json
      end

      private

      def load_content_type(slug)
        @content_type = site.content_types.where(slug: slug, public_submission_enabled: true).first
      end

      def create_entry(attributes)
        ::Mongoid::Fields::I18n.with_locale(locale) do
          service.public_create(attributes, { ip_address: ip_address })
        end
      end

      def make_entity(entry)
        entity = entry.to_steam(@content_type)
        Locomotive::Steam::Decorators::I18nDecorator.new(entity, locale)
      end

      def service
        Locomotive::ContentEntryService.new(@content_type, nil)
      end

    end

  end
end
