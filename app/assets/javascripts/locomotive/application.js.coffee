#= require_self
#= require_tree .
#= require_tree ./utils
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Locomotive =
  mount_on: '/locomotive'
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}