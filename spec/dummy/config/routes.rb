Rails.application.routes.draw do

  mount Locomotive::Engine => '/locomotive'

  match '/foo' => 'foo#index', :as => 'foo'

end
