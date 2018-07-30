module Locomotive
  module API

    module ExceptionRescuers

      extend ActiveSupport::Concern

      included do

        rescue_from :all do |e|
          Rails.logger.error "[API] " + e.message + "\n\t" + e.backtrace.join("\n\t")

          error!({ error: e.message }, 500)
        end

        rescue_from ::Mongoid::Errors::DocumentNotFound do
          error!({ error: 'Resource not found' }, 404)
        end

        rescue_from ::Mongoid::Errors::Validations do |e|
          error!({ error: 'Resource invalid', attributes: e.document.errors.messages }, 422)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          attributes = {}.tap do |hash|
            e.errors.each { |k, v| hash[k.first.match(/\[([^\[\]]+)\]/).try(:[], 1) || k.first] = v.map { |error| error.to_s } }
          end
          error!({ error: 'Resource invalid', attributes: attributes }, 422)
        end

        rescue_from Pundit::NotAuthorizedError do
          error!({ error: 'Unauthorized' }, 401)
        end

      end

    end

  end
end
