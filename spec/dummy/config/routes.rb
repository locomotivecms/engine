Rails.application.routes.draw do

  match '/_api' => 'locomotive/api/documentation#show', via: :all

  match '/foo' => 'foo#index', as: 'foo', via: :all

  mount Locomotive::Engine => '/locomotive', as: 'locomotive'

end
