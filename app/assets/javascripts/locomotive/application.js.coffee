#= require_self
#= require_tree ./utils
#= require_tree ./models
#= require_tree ./views

window.Locomotive =
  mounted_on:   '/locomotive' # default path
  Models:       {}
  Collections:  {}
  Views:        {}

window.Locomotive.Views.Memberships = {}