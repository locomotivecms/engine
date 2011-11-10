class Locomotive.Views.ApplicationView extends Backbone.View

  el: 'body'

  render: ->
    @render_flash_messages(@options.flash)

    if @options.view?
      @view = new @options.view
      @view.render()

    return @

  render_flash_messages: (messages) ->
    _.each messages, (couple) ->
      $.growl couple[0], couple[1]
