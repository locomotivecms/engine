module Locomotive
  module Liquid
    module Drops
      class CurrentUser < Base
        def logged_in?
          false
        end
      end
    end
  end
end
