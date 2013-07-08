Locomotive::Engine.routes.draw do

  # authentication
  devise_for :locomotive_account,
    class_name:   'Locomotive::Account',
    path:         '',
    path_prefix:  nil,
    failure_app:  'Locomotive::Devise::FailureApp',
    controllers:  { sessions: 'locomotive/sessions', passwords: 'locomotive/passwords' }

  devise_scope :locomotive_account do
    match '/'         => 'sessions#new'
    delete 'signout'  => 'sessions#destroy', as: :destroy_locomotive_session
  end

  root to: 'pages#index'

  resources :pages do
    put :sort, on: :member
    get :get_path, on: :collection
  end

  resources :snippets

  resources :sites

  resource :current_site, controller: 'current_site'

  resources :accounts

  resource :my_account, controller: 'my_account' do
    put :regenerate_api_key, on: :member
  end

  resources :memberships

  resources :theme_assets do
    get :all, action: 'index', on: :collection, defaults: { all: true }
  end

  resources :translations

  resources :content_assets

  resources :content_types

  resources :content_entries, path: 'content_types/:slug/entries' do
    put :sort,    on: :collection
    get :export,  on: :collection
  end

  # installation guide
  match '/installation'       => 'installation#show', defaults: { step: 1 }, as: :installation
  match '/installation/:step' => 'installation#show', as: :installation_step

end

Rails.application.routes.draw do

  # API
  namespace :locomotive, module: 'locomotive' do
    namespace :api do

      resources :tokens, only: [:create, :destroy]

      resource  :current_site, controller: 'current_site', only: [:show, :update, :destroy]

      resources :memberships, only: [:index, :show, :create, :update, :destroy]

      resource  :my_account, controller: 'my_account', only: :show

      resources :accounts, only: [:index, :show, :create, :destroy]

      with_options only: [:index, :show, :create, :update, :destroy] do |api|

        api.resources :sites

        api.resources :pages

        api.resources :snippets

        api.resources :content_types

        api.resources :content_entries, path: 'content_types/:slug/entries'

        api.resources :theme_assets

        api.resources :translations

        api.resources :content_assets
      end
    end
  end

  # sitemap
  match '/sitemap.xml'  => 'locomotive/public/sitemaps#show', format: 'xml'

  # robots.txt
  match '/robots.txt'   => 'locomotive/public/robots#show', format: 'txt'

  # public content entry submissions
  resources :locomotive_entry_submissions, controller: 'locomotive/public/content_entries', path: 'entry_submissions/:slug'

  # magic urls
  match '/_admin'               => 'locomotive/public/pages#show_toolbar'
  match ':locale/_admin'        => 'locomotive/public/pages#show_toolbar', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match ':locale/*path/_admin'  => 'locomotive/public/pages#show_toolbar', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match '*path/_admin'          => 'locomotive/public/pages#show_toolbar'

  match '/_edit'                => 'locomotive/public/pages#edit'
  match ':locale/_edit'         => 'locomotive/public/pages#edit', page_path: 'index', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match ':locale/*path/_edit'   => 'locomotive/public/pages#edit', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match '*path/_edit'           => 'locomotive/public/pages#edit'

  root to:                      'locomotive/public/pages#show'
  match ':locale'               => 'locomotive/public/pages#show', page_path: 'index', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match ':locale/*path'         => 'locomotive/public/pages#show', locale: /(#{Locomotive.config.site_locales.join('|')})/
  match '*path'                 => 'locomotive/public/pages#show'
end
