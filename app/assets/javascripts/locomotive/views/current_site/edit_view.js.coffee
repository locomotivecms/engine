#= require ../shared/form_view

Locomotive.Views.CurrentSite ||= {}

class Locomotive.Views.CurrentSite.EditView extends Locomotive.Views.Shared.FormView

  el: '.main'

  initialize: ->
    @attach_events_on_private_access_attribute()
    @display_locale_picker_only_for_seo()

  attach_events_on_private_access_attribute: ->
    @$('#site_private_access').on 'switchChange.bootstrapSwitch', (event, state) ->
      $inputs = $('.locomotive_site_password')
      $inputs.toggleClass('hide')

  display_locale_picker_only_for_seo: ->
    $picker = @$('.locale-picker-btn-group').css(visibility: 'hidden')

    @$('a[data-toggle="tab"]').on 'shown.bs.tab', (event) ->
      if $(event.target).attr('href') == '#seo' then $picker.css(visibility: '') else $picker.css(visibility: 'hidden')
