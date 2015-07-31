#= require ../shared/form_view

Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  initialize: ->
    @attach_events_on_redirect_attribute()

  attach_events_on_redirect_attribute: ->
    @$('#page_redirect').on 'switchChange.bootstrapSwitch', (event, state) ->
      $inputs = $('.locomotive_page_redirect_url, .locomotive_page_redirect_type')
      $inputs.toggleClass('hide')
