Locomotive.Views.InlinEditor ||= {}

class Locomotive.Views.InlinEditor.ToolbarView extends Backbone.View

  tagName: 'div'

  className: 'toolbar-view'

  events:
    'change .editing-mode input[type=checkbox]':  'toggle_editing_mode'
    'click  .back a':                             'back'
    'click  .element-actions a.save':             'save_modifications'
    'click  .element-actions a.cancel':           'cancel_modifications'

  initialize: ->
    super

  render: ->
    super
    $(@el).html(ich.toolbar(@model.toJSON()))

    @enable_editing_mode_checkbox()

    @

  notify: (aloha_editable) ->
    console.log('editable_element has been modified...')

    window.bar = aloha_editable

    element_id  = aloha_editable.obj.attr('data-element-id')
    @model.get('editable_elements').get(element_id).set
      content: aloha_editable.getContents()

    @$('.element-actions').show()

  save_modifications: (event) ->
    event.stopPropagation() & event.preventDefault()

    previous_attributes = _.clone @model.attributes

    @model.save {},
      success: (model, response, xhr) =>
        model.attributes = previous_attributes
        @$('.element-actions').hide()
      error: (model, xhr) =>
        @$('.element-actions').hide()

  cancel_modifications: (event) ->
    event.stopPropagation() & event.preventDefault()
    @options.target[0].contentWindow.location.href = @options.target[0].contentWindow.location.href

  back: (event) ->
    event.stopPropagation() & event.preventDefault()
    window.location.href = @model.get('edit_url')

  enable: ->
    @options.target[0].contentWindow.Aloha.settings.locale = window.locale;
    @$('.editing-mode').show()

  toggle_editing_mode: (event) ->
    return if @editable_elements() == null

    if $(event.target).is(':checked')
      @editable_elements().aloha()
    else
      @editable_elements().removeClass('aloha-editable-highlight').mahalo()

  editable_elements: ->
    if @options.target[0].contentWindow.Aloha
      @options.target[0].contentWindow.Aloha.jQuery('.editable-long-text, .editable-short-text')
    else
      null

  enable_editing_mode_checkbox: ->
    @$('.editing-mode input[type=checkbox]').checkToggle
      on_label_color:   '#fff'
      off_label_color:  '#bbb'

  refresh: ->
    console.log('refreshing toolbar...')

    @$('h1').html(@model.get('title'))

    if @$('.editing-mode input[type=checkbox]').is(':checked')
      @$('.editing-mode div.switchArea').trigger('click')

    @$('.element-actions').hide()


  remove: ->
    super