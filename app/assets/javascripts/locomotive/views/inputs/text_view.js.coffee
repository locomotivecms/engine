Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.TextView extends Backbone.View

  events:
    'change input[type=text]':    'content_change'
    'paste input[type=text]':     'content_change'
    'keyup input[type=text]':     'content_change'
    'highlight input[type=text]': 'highlight'
    'change textarea':            'content_change'
    'paste textarea':             'content_change'
    'keyup textarea':             'content_change'
    'highlight textarea':         'highlight'

  content_change: (event) ->
    PubSub.publish 'inputs.text_changed',
      view:     @
      content:  @text_value($(event.target))

    return true

  text_value: (textarea) ->
    textarea.val()

  highlight: (event) ->
    $(event.target).focus()
