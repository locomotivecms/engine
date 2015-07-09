module Locomotive
  module Steam

    class APIEntrySubmissionService < Struct.new(:site, :locale)

      def submit(slug, attributes = {})
        load_content_type(slug)
        create_entry(attributes)
      end

      def to_json(entry)
        entity = Locomotive::API::Entities::ContentEntryEntity.represent(entry)
        entity.to_json
      end

      private

      def create_entry(attributes)
        ::Mongoid::Fields::I18n.with_locale(locale) do
          form = Locomotive::API::Forms::ContentEntryForm.new(@content_type, attributes)
          service.create(form.serializable_hash)
        end
      end

      def load_content_type(slug)
        @content_type = site.content_types.where(slug: slug).first
      end

      def service
        Locomotive::ContentEntryService.new(@content_type, nil)
      end

    end

  end
end
