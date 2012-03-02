module Locomotive
  module Liquid
    module Drops
      class CurrentUser < Base

        include ::Rails.application.routes.url_helpers

        def logged_in?
          _source.present?
        end
        def name
          _source.name if logged_in?
        end
        def email
          _source.email if logged_in?
        end
        def logout_path
          destroy_admin_session_path
        end
        def login_path
          new_admin_session_path
        end
      end
    end
  end
end
