Locomotive.Views.InlinEditor ||= {}

class Locomotive.Views.InlinEditor.ToolbarView extends Backbone.View

  tagName: 'div'

  className: 'toolbar-view'

  events:
    'change .edit input[type=checkbox]': 'toggle_inline_editing'

  initialize: ->
    super

  render: ->
    super
    $(@el).html(ich.toolbar(@model.toJSON()))

    @enable_edit_checkbox()

    @

  toggle_inline_editing: (event) ->
    console.log('toggle_inline_editing !!!')
    if $(event.target).is(':checked')
      @editable_elements().aloha()
    else
      @editable_elements().removeClass('aloha-editable-highlight').mahalo()

  editable_elements: ->
    @options.target[0].contentWindow.Aloha.jQuery('.editable-long-text, .editable-short-text')

  enable_edit_checkbox: ->
    @$('.edit input[type=checkbox]').checkToggle
      on_label_color:   '#fff'
      off_label_color:  '#bbb'

  refresh: ->
    console.log('refreshing...')
    @

  remove: ->
    super