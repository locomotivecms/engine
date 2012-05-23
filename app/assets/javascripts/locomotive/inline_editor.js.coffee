#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require underscore
#= require backbone
#= require locomotive/backbone.sync
#= require locomotive/growl
#= require locomotive/handlebars
#= require locomotive/ICanHandlebarz
#= require locomotive/resize
#= require locomotive/toggle
#= require_self
#= require_tree ./utils
#= require_tree ./models
#= require_tree ./views/content_assets
#= require_tree ./views/inline_editor

window.Locomotive =
  mounted_on:   '/locomotive' # default path
  Models:       {}
  Collections:  {}
  Views:        {}