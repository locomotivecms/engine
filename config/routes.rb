# Locomotive::Application.routes.draw do |map|
Locomotive::Engine.routes.draw do

  # # admin authentication
  # devise_for :admin, :class_name => 'Account', :controllers => { :sessions => 'admin/sessions', :passwords => 'admin/passwords' }
  #
  # as :admin do
  #   get '/admin' => 'admin/sessions#new'
  # end

  # locomotive authentication
  devise_for :locomotive_account,
    :class_name   => 'Locomotive::Account',
    :path         => '',
    :path_prefix  => nil,
    :failure_app  => 'Locomotive::Devise::FailureApp',
    :controllers  => { :sessions => 'locomotive/sessions', :passwords => 'locomotive/passwords' } do
      match '/' => 'sessions#new'
  end

  root :to => 'pages#index'

  resources :pages do
    put :sort, :on => :member
    get :get_path, :on => :collection
  end

  resources :snippets

  resources :sites

  resource :current_site, :controller => 'current_site'

  resources :accounts

  resource :my_account, :controller => 'my_account'

  resources :memberships

  resources :theme_assets do
    get :all, :action => 'index', :on => :collection, :defaults => { :all => true }
  end

  # resources :assets # TODO: conflict name

  resources :content_types

  resources :contents, :path => 'content_types/:slug/contents' do
    put :sort, :on => :collection
  end

  resources :api_contents, :path => 'api/:slug/contents', :controller => 'api_contents', :only => [:create]

  resources :custom_fields, :path => 'custom/:parent/:slug/fields'

  resources :cross_domain_sessions, :only => [:new, :create]

  resource :import, :only => [:new, :show, :create], :controller => 'import'

  resource :export, :only => [:new], :controller => 'export'

  # installation guide
  match '/installation'       => 'installation#show', :defaults => { :step => 1 }, :as => :installation
  match '/installation/:step' => 'installation#show', :as => :installation_step
end

Rails.application.routes.draw do
  # sitemap
  match '/sitemap.xml'  => 'locomotive/sitemaps#show', :format => 'xml'

  # robots.txt
  match '/robots.txt'   => 'locomotive/robots#show', :format => 'txt'

  # magic urls
  match '/'             => 'locomotive/rendering#show'
  match '*path/edit'    => 'locomotive/rendering#edit'
  match '*path'         => 'locomotive/rendering#show'
end