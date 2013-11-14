module Locomotive
  module Extensions
    module Site
      module Timezone

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :timezone_name, type: ::String, default: 'UTC'

          # ## validations ##
          validate :wrong_timezone_name
        end

        def timezone
          @timezone ||= ActiveSupport::TimeZone.new(self.timezone_name)
        end

        protected

        def wrong_timezone_name
          unless ActiveSupport::TimeZone.new(self.timezone_name)
            self.errors.add :timezone, I18n.t(:wrong_timezone_name, scope: [:errors, :messages, :site])
          end
        end

      end
    end
  end
end