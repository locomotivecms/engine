#= require_self
#= require_tree .
#= require_tree ./utils
#= require_tree ./models
#= require_tree ./views

window.Locomotive =
  mount_on: '/locomotive'
  Models: {}
  Collections: {}
  Views: {}

window.Locomotive.Views.Memberships = {}