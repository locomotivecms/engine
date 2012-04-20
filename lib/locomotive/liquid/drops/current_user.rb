module Locomotive	
  module Liquid
    module Drops
      class CurrentUser < Base

        def logged_in?
          _source.present?
        end

	def name
          _source.name if logged_in?
        end

        def email
          _source.email if logged_in?
        end

      end
    end
  end
end
