Locomotive::Engine.routes.draw do

  # Authentication
  devise_for :locomotive_account,
    class_name:   'Locomotive::Account',
    skip:         [:registrations],
    path:         '',
    failure_app:  'Locomotive::Devise::FailureApp'

  devise_scope :locomotive_account do
    if Locomotive.config.enable_registration
      get     'sign_up'  => 'registrations#new',    as: :sign_up
      post    'sign_up'  => 'registrations#create'
    end
    get     'sign_in'  => 'sessions#new',         as: :sign_in
    delete  'sign_out' => 'sessions#destroy',     as: :sign_out
  end

  root to: 'sites#index'

  resources :sites

  resource :my_account, controller: 'my_account' do
    put :regenerate_api_key, on: :member
  end

  # Back-office: current site, pages, content entries, assets and the site settings
  scope ':site_handle' do

    get '/',          to: 'dashboard#show'
    get 'dashboard',  to: 'dashboard#show', as: :dashboard

    get 'developers', to: 'developers_documentation#show', as: :developers_documentation

    resources :pages do
      put :sort, on: :member
      get :get_path, on: :collection

      resource :content, controller: 'page_content', only: [:edit, :update]
      get 'content/edit/*nav', to: 'page_content#edit'
    end

    resources :editable_elements, only: [:index, :update_all], path: 'pages/:page_id/editable_elements' do
      patch :update_all, on: :collection
    end

    resources :current_site_metafields, only: [:index, :update_all] do
      patch :update_all, on: :collection
    end

    resources :accounts

    resources :memberships

    resources :translations do
      delete :bulk_destroy, on: :collection
    end

    resources :search_for_resources, only: [:index]

    resources :content_assets do
      post :bulk_create, on: :collection
    end

    resource :public_submission_accounts, only: [:edit, :update], path: 'content_types/:slug/public_submission_accounts' do
      get :new_account
    end

    resources :content_entries, path: 'content_types/:slug/entries' do
      get :show_in_form,      on: :collection
      put :sort,              on: :collection
      get :export,            on: :collection
      delete :bulk_destroy,   on: :collection

      resource :impersonation, only: [:create], controller: 'content_entry_impersonations'
    end

    namespace :custom_fields, path: 'content_types/:slug/fields/:name' do
      resource :select_options, only: [:edit, :update] do
        get :new_option
      end
    end

    resource :current_site, controller: 'current_site' do
      get :new_domain
      get :new_locale
      get :new_url_redirection
    end

    # Preview mode handled by Steam
    mount Locomotive::Steam.to_app => '/preview', as: 'preview', anchor: false

  end
end
