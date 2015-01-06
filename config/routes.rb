Locomotive::Engine.routes.draw do

  # authentication
  devise_for :locomotive_account,
    class_name:   'Locomotive::Account',
    path:         '',
    path_prefix:  nil,
    failure_app:  'Locomotive::Devise::FailureApp',
    controllers:  { sessions: 'locomotive/sessions', passwords: 'locomotive/passwords' }

  # authenticated :locomotive_account do
  #   root to: 'dashboard#show'
  # end

  devise_scope :locomotive_account do
    match '/'         => 'sessions#new', via: :all
    delete 'signout'  => 'sessions#destroy', as: :destroy_locomotive_session
  end

  # root to: 'dashboard#show'

  get 'dashboard', to: 'dashboard#show', as: :dashboard
  # resource :dashboard, controller: 'dashboard', only: :show

  resources :pages do
    put :sort, on: :member
    get :get_path, on: :collection
  end

  resources :snippets

  resources :sites

  resource :current_site, controller: 'current_site' do
    get :new_domain
    get :new_locale
  end

  resources :accounts

  resource :my_account, controller: 'my_account' do
    put :regenerate_api_key, on: :member
  end

  resources :memberships

  resources :theme_assets do
    get :all, action: 'index', on: :collection, defaults: { all: true }
  end

  resources :translations

  resources :content_assets do
    post :bulk_create, on: :collection
  end

  resources :content_types

  resources :content_entries, path: 'content_types/:slug/entries' do
    get :show_in_form,  on: :collection
    put :sort,          on: :collection
    get :export,        on: :collection
  end

  namespace :custom_fields, path: 'content_types/:slug/fields/:name' do
    resource :select_options, only: [:edit, :update] do
      get :new_option
    end
  end

  # installation guide
  match '/installation'       => 'installation#show', defaults: { step: 1 }, as: :installation, via: :all
  match '/installation/:step' => 'installation#show', as: :installation_step, via: :all

end

Rails.application.routes.draw do

  # API
  namespace :locomotive, module: 'locomotive' do
    namespace :api do

      get 'version', to: 'version#show'

      resources :tokens, only: [:create, :destroy]

      resource  :current_site, controller: 'current_site', only: [:show, :update, :destroy]

      resources :memberships, only: [:index, :show, :create, :update, :destroy]

      resource  :my_account, controller: 'my_account', only: [:show, :create, :update]

      with_options only: [:index, :show, :create, :update, :destroy] do |api|

        api.resources :accounts

        api.resources :sites

        api.resources :pages

        api.resources :snippets

        api.resources :content_types

        api.resources :content_entries, path: 'content_types/:slug/entries' do
          delete :index, on: :collection, action: :destroy_all
        end

        api.resources :theme_assets

        api.resources :translations

        api.resources :content_assets
      end
    end
  end

  # sitemap
  get '/sitemap.xml', to: 'locomotive/public/sitemaps#show', format: 'xml'

  # robots.txt
  get '/robots.txt', to: 'locomotive/public/robots#show', format: 'txt'

  # public content entry submissions
  resources :locomotive_entry_submissions, controller: 'locomotive/public/content_entries', path: 'entry_submissions/:slug'

  # magic urls
  # match '/_admin'               => 'locomotive/public/pages#show_toolbar'
  # match '*path/_admin'          => 'locomotive/public/pages#show_toolbar'

  # match '/_edit'                => 'locomotive/public/pages#edit'
  # match '*path/_edit'           => 'locomotive/public/pages#edit'

  constraints Locomotive::Routing::PostContentEntryConstraint.new do
    # root to:                    'locomotive/public/content_entries#create', path: 'index', via: :post
    post  '/',    to: 'locomotive/public/content_entries#create'
    post '*path', to: 'locomotive/public/content_entries#create'
  end

  # root to:                      'locomotive/public/pages#show'
  get '/',        to: 'locomotive/public/pages#show'
  match '*path'   => 'locomotive/public/pages#show', via: :all
end
