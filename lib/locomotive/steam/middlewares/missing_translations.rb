module Locomotive
  module Steam
    module Middlewares

      class MissingTranslations

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          find_and_persist_missing_translations(env['locomotive.site']) do
            @app.call(env)
          end
        end

        def find_and_persist_missing_translations(site)
          translations = []

          subscription = ActiveSupport::Notifications.subscribe('steam.missing_translation') do |name, start, finish, id, payload|
            translations << { key: payload[:input], values: { payload[:input] => false } }
          end

          yield.tap do
            ActiveSupport::Notifications.unsubscribe(subscription)
            persist_missing_translations(site, translations) unless translations.empty?
          end
        end

        def persist_missing_translations(site, translations)
          new_translations = []

          translations.each do |attributes|
            if existing = site.translations.where(key: attributes[:key]).first
              existing.update_attribute :values, existing.values.merge(attributes[:values])
            else
              new_translations << attributes
            end
          end

          site.translations.create(new_translations) unless new_translations.empty?
        end

      end

    end
  end
end
