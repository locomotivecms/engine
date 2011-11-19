Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerItemView extends Backbone.View

  tagName: 'li'

  className: 'asset'

  events:
    'click h4 a, .icon, .image':  'select_asset'
    'click a.remove':             'remove_asset'

  render: ->
    $(@el).html(ich.content_asset(@model.toJSON()))

    return @

  select_asset: (event) ->
    event.stopPropagation() & event.preventDefault()
    @on_select(@model)

  on_select: ->
    @options.parent.options.on_select(@model) if @options.parent.options.on_select

  remove_asset: (event) ->
    event.stopPropagation() & event.preventDefault()

    message = $(event.target).attr('data-confirm') || $(event.target).parent().attr('data-confirm')

    @model.destroy() if confirm(message)
