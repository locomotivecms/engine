module Locomotive
  module Steam

    class APIContentEntryService < ContentEntryService

      include Locomotive::Steam::Services::Concerns::Decorator

      attr_accessor_initialize :content_type_repository, :repository, :locale, :request

      def create(type_slug, attributes, as_json = false)
        with_form(type_slug, attributes, as_json) do |_attributes|
          @content_type.entries.create(_attributes)
        end
      end

      def update(type_slug, id_or_slug, attributes, as_json = false)
        with_form(type_slug, attributes, as_json) do |_attributes|
          entry = @content_type.entries.by_id_or_slug(id_or_slug).first

          entry.update_attributes(_attributes)

          entry
        end
      end

      private

      def with_form(type_slug, attributes, as_json, &block)
        load_content_type(type_slug)

        useTempfiles(attributes)

        ::Mongoid::Fields::I18n.with_locale(self.locale) do
          form  = Locomotive::API::Forms::ContentEntryForm.new(@content_type, attributes)

          entry = yield(form.serializable_hash)

          make_entity(entry, as_json)
        end
      end

      def useTempfiles(attributes)
        # kind of marshal/unmarshal mechanism :-)
        attributes.each do |key, value|
          if value.is_a?(Hash) && value['tempfile'].present? && value['tempfile'].is_a?(String) && value['filename'].present?
            attributes[key]['tempfile'] = File.open(attributes[key]['tempfile'])
          end
        end
      end

      def make_entity(entry, as_json)
        entity = entry.to_steam(@content_type)
        decorated_entity = Locomotive::Steam::Decorators::I18nDecorator.new(entity, locale)
        _json_decorate(decorated_entity, as_json)
      end

      def load_content_type(slug)
        @content_type = site.content_types.where(slug: slug).first
      end

      def site
        request.env['locomotive.site']
      end

    end

  end
end

