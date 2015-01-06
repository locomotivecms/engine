Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.DocumentPickerView extends Backbone.View

  initialize: ->
    super
    @$input   = @$('input[type=hidden]')
    @$link    = @$('a.edit')

  render: ->
    label = @$input.data('label')

    Select2.helpers.build @$input,
      allowClear:     true
      initSelection:  (element, callback) ->
        callback(text: label)

    # hide the edit button if the user changes the selected document
    @$input.on 'select2-selecting', (el) =>
      @$link.addClass('hide')

  remove: ->
    @$input.select2('destroy')
    super
