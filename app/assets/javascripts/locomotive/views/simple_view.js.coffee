class Locomotive.Views.SimpleView extends Backbone.View

  el: 'body'

  render: ->
    @render_flash_messages(@options.flash)

    # render page view
    if @options.view?
      @view = new @options.view(@options.view_data || {})
      @view.render()

    return @

  render_flash_messages: (messages) ->
    _.each messages, (couple) ->
      Locomotive.notify couple[1], couple[0]
