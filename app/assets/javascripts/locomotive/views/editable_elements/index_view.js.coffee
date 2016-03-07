Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.IndexView extends Backbone.View

  el: '.content-main'

  events:
    'click .actionbar .actionbar-trigger': 'toggle_preview'

  initialize: ->
    _.bindAll(@, 'shrink_preview')

    view_options = if $('body').hasClass('live-editing') then {} else { el: '.main' }

    @tokens = [
      PubSub.subscribe 'editable_elements.highlighted_text', @shrink_preview
    ]

    # order is important here
    @views = [
      new Locomotive.Views.EditableElements.EditView(view_options),
      new Locomotive.Views.EditableElements.IframeView(parent_view: @)
    ]

  render: ->
    super()
    _.invoke @views, 'render'

  toggle_preview: (event) ->
    $(@el).toggleClass('actionbar-closed')

  shrink_preview: (event) ->
    $(@el).removeClass('actionbar-closed')

  replace_edit_view: (url) ->
    @views[0].remove()
    $(@views[0].el).load url, =>
      (@views[0] = new Locomotive.Views.EditableElements.EditView()).render()

  remove: ->
    super()
    _.each @tokens, (token) -> PubSub.unsubscribe(token)
    _.invoke @views, 'remove'
