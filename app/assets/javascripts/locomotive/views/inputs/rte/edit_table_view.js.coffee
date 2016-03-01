Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.EditTableView extends Backbone.View

  initialize: ->
    _.bindAll(@, 'hide')

    @$link    = @$('a[data-wysihtml5-hiddentools=table]')
    @$content = @$link.next('.table-dialog-content')
    @editor   = @options.editor

  render: ->
    return if @$link.size() == 0

    @create_popover()
    @attach_events()

  create_popover: ->
    @$link.popover
      placement:  'bottom'
      content:    @$content.html()
      html:       true
      title:      undefined

  attach_events: ->
    @editor.on 'tableunselect:composer', @hide

  detach_events: ->
    @editor.stopObserving 'tableselect:composer', @hide

  hide: ->
    @$link.popover('hide')

  remove: ->
    @$link.popover('destroy')
    @$('.popover').remove()

