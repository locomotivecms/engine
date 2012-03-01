module Locomotive
  module Liquid
    module Drops
      class CurrentUser < Base
        def logged_in?
          _source.present?
        end
      end
    end
  end
end
