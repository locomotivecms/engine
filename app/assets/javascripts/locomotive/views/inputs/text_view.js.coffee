Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.TextView extends Backbone.View

  events:
    'change input[type=text]':  'content_change'
    'paste input[type=text]':   'content_change'
    'keyup input[type=text]':   'content_change'
    'change textarea':          'content_change'
    'paste textarea':           'content_change'
    'keyup textarea':           'content_change'

  content_change: (event) ->
    PubSub.publish 'inputs.text_changed',
      view:     @
      content:  $(event.target).val()
