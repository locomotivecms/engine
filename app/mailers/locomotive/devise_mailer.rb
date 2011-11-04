module Locomotive
  class DeviseMailer < ::Devise::Mailer

    include ::Locomotive::Engine.routes.url_helpers

  end

end