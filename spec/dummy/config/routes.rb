Rails.application.routes.draw do

  match '/_api' => 'locomotive/api/documentation#show'

  mount Locomotive::Engine => '/locomotive', :as => 'locomotive'

  match '/foo' => 'foo#index', :as => 'foo'

end
