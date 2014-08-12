# https://github.com/jashkenas/backbone/issues/2822
View = Backbone.View
Backbone.View = View.extend
  constructor: (options) ->
    @options = options || {}
    View.apply(@, arguments)
