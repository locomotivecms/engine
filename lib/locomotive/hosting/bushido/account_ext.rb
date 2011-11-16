module Locomotive
  module Hosting
    module Bushido

      module AccountExt

        extend ActiveSupport::Concern

        included do

          field :bushido_user_id, :type => String

        end

        module InstanceMethods

          def cas_extra_attributes=(extra_attributes)
            return if extra_attributes.blank?

            self.update_attributes({
              :email            => extra_attributes['email'],
              :name             => "#{extra_attributes['first_name']} #{extra_attributes['last_name']}",
              :locale           => extra_attributes['locale'],
            })
          end

        end

      end

    end
  end
end
