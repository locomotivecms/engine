module Locomotive
  module Concerns
    module Site
      module PrivateAccess

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :private_access, type: Boolean, default: false
          field :password

        end

      end
    end
  end
end
