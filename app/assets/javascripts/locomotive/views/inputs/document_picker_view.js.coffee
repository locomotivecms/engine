Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.DocumentPickerView extends Backbone.View

  initialize: ->
    super
    @$input   = @$('select')
    @$link    = @$('a.edit')

  render: ->
    label = @$input.data('label')

    Select2Helpers.build @$input,
      allowClear: true

    # hide the edit button if the user changes the selected document
    @$input.data('select2').on 'unselect', (el) =>
      @$link.addClass('hide')
      setTimeout ( => @$input.select2('close') ), 1

    @$input.on 'change', (el) => @$link.addClass('hide')

  remove: ->
    @$input.select2('destroy')
    super
