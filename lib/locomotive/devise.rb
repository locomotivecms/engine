# patches for devise here

# http://blog.plataformatec.com.br/2013/11/e-mail-enumeration-in-devise-in-paranoid-mode/
# Put this inside config/initializers/devise_paranoid_fix.rb
require 'devise/strategies/database_authenticatable'

Devise::Strategies::DatabaseAuthenticatable.class_eval do
  def authenticate!
    resource  = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
    encrypted = false

    return fail(:invalid) unless resource

    if validate(resource){ encrypted = true; resource.valid_password?(password) }
      resource.after_database_authentication
      success!(resource)
    end

    mapping.to.new.password = password if !encrypted && Devise.paranoid
    fail(:not_found_in_database) unless resource
  end
end