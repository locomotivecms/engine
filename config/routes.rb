# Locomotive::Application.routes.draw do |map|
Rails.application.routes.draw do

  constraints(Locomotive::Routing::DefaultConstraint) do
    root :to => 'home#show'
  end

  # admin authentication
  devise_for :admin, :class_name => 'Account', :controllers => { :sessions => 'admin/sessions', :passwords => 'admin/passwords' }

  # admin interface for each website
  namespace 'admin' do
    root :to => 'pages#index'

    resources :pages do
      put :sort, :on => :member
      get :get_path, :on => :collection
    end

    resources :snippets

    resources :sites

    resource :current_site

    resources :accounts

    resource :my_account

    resources :memberships

    resources :theme_assets

    resources :asset_collections

    resources :assets, :path => 'asset_collections/:collection_id/assets'

    resources :content_types

    resources :contents, :path => 'content_types/:slug/contents' do
      put :sort, :on => :collection
    end

    resources :api_contents, :path => 'api/:slug/contents', :controller => 'api_contents', :only => [:create]

    resources :custom_fields, :path => 'custom/:parent/:slug/fields'

    resources :cross_domain_sessions, :only => [:new, :create]
  end

  # sitemap
  match '/sitemap.xml' => 'admin/sitemaps#show', :format => 'xml'

  # magic urls
  match '/' => 'admin/rendering#show'
  match '*path' => 'admin/rendering#show'
end
