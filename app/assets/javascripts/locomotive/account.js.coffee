#= require jquery
#= require jquery_ujs
#= require_self
#= require underscore/underscore
#= require locomotive/bootstrap-notify
#= require ./utils/notify

window.Locomotive = {}

$ ->
  _.each window.flash_messages, (couple) ->
      Locomotive.notify couple[1], couple[0]
