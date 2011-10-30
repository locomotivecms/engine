Rails.application.routes.draw do

  # locomotive authentication
  devise_for :account, :class_name => 'Locomotive::Account', :controllers => { :sessions => 'locomotive/sessions', :passwords => 'locomotive/passwords' }

  mount Locomotive::Engine => '/locomotive'

end
