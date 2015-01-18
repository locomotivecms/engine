Rails.application.routes.draw do

  match '/foo' => 'foo#index', as: 'foo', via: :all

  mount Locomotive::Engine => '/locomotive', as: 'locomotive'

end
