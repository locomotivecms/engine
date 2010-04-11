Locomotive::Application.routes.draw do |map|
  
  constraints(Locomotive::Routing::DefaultConstraint) do
    root :to => 'home#show'
  end
  
  match '/' => 'pages#show'
end
