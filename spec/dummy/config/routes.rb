Rails.application.routes.draw do

  match '/_api' => 'locomotive/api/documentation#show'

  match '/foo' => 'foo#index', as: 'foo'

  mount Locomotive::Engine => '/locomotive', as: 'locomotive'

end
