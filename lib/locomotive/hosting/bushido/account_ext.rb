module Locomotive
  module Hosting
    module Bushido

      module AccountExt

        extend ActiveSupport::Concern

        included do

          field :bushido_user_id, :type => Integer

        end

      end

    end
  end
end