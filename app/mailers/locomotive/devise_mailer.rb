module Locomotive
  class DeviseMailer < ::Devise::Mailer

    default :from => Locomotive.config.mailer_sender

    include ::Locomotive::Engine.routes.url_helpers

  end

end