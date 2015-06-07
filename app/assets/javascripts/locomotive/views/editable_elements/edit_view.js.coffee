Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  el: '.content > .inner'

  initialize: ->
    super

    $form = $('form.edit_page')

    $form.on 'ajax:success', (event, data, status, xhr) =>
      $response = $(data)
      window.foo = $response

