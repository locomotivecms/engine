Locomotive::Application.routes.draw do |map|
  
  constraints(Locomotive::Routing::DefaultConstraint) do
    root :to => 'home#show'
  end
  
  # admin authentication
  Devise.register(:accounts, {}) # bypass the devise_for :accounts  
  scope '/admin' do
    get 'login' => 'devise/sessions#new', :as => :new_account_session
    post 'login' => 'devise/sessions#create', :as => :account_session
    get 'logout' => 'devise/sessions#destroy', :as => :destroy_account_session    
    resource :password, :only => [:new, :create, :edit, :update], :controller => 'devise/passwords'
  end
  
  # admin interface for each website
  namespace 'admin' do
    # TODO
  end
  
  match '/' => 'pages#show'
end
