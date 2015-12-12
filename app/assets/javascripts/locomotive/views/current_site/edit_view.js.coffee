#= require ../shared/form_view

Locomotive.Views.CurrentSite ||= {}

class Locomotive.Views.CurrentSite.EditView extends Locomotive.Views.Shared.FormView

  el: '.main'

  initialize: ->
    @attach_events_on_private_access_attribute()

  attach_events_on_private_access_attribute: ->
    @$('#site_private_access').on 'switchChange.bootstrapSwitch', (event, state) ->
      $inputs = $('.locomotive_site_password')
      $inputs.toggleClass('hide')
