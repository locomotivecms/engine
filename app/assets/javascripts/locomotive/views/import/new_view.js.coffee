Locomotive.Views.Import ||= {}

class Locomotive.Views.Import.NewView extends Backbone.View

  el: '#content'

  render: ->
    super()

    @enable_checkboxes()

  enable_checkboxes: ->
    @$('.formtastic input[type=checkbox]').checkToggle()