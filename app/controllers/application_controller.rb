class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # before_filter :set_locale
  # 
  # protected
  # 
  # def set_locale
  #   I18n.locale = 'fr'
  # end
end
