
View = Backbone.View

Backbone.View = View.extend
  # https://github.com/jashkenas/backbone/issues/2822
  constructor: (options) ->
    @options = options || {}
    View.apply(@, arguments)

  replace: ($new_el) ->
    $(@el).hide()

    $new_el.insertAfter($(@el))

    _view = new @constructor(el: $new_el)
    _view.render()

    @remove()

    _view
