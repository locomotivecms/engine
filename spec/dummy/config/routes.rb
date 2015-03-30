Rails.application.routes.draw do

  match '/foo' => 'foo#index', as: 'foo', via: :all

  mount Locomotive::Engine => '/locomotive', as: 'locomotive'

  mount Locomotive::Steam::Server.to_app => '/', anchor: false

end
