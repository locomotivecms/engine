module Locomotive
  module Concerns
    module ContentEntry
      module Notifications

        extend ActiveSupport::Concern

        included do

          ## callbacks ##
          after_create  :send_notifications, if: :notifications?

        end

        def notifications?
          self.content_type.public_submission_enabled? &&
          !self.content_type.public_submission_accounts.blank?
        end

        def send_notifications
          account_ids = self.content_type.public_submission_accounts.map(&:to_s)

          self.site.accounts.each do |account|
            next unless account_ids.include?(account._id.to_s)

            Locomotive::Notifications.new_content_entry(account, self).deliver
          end
        end

      end
    end
  end
end
