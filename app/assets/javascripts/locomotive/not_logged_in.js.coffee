#= require jquery
#= require_self
#= require underscore
#= require locomotive/bootstrap-notify
#= require ./utils/notify

window.Locomotive = {}

$ ->
  _.each window.flash_messages, (couple) ->
      Locomotive.notify couple[1], couple[0]
