Locomotive::Application.routes.draw do |map|
  
  constraints(Locomotive::Routing::DefaultConstraint) do
    root :to => 'home#show'
    devise_for :accounts
  end
  
  match '/' => 'pages#show'
end
