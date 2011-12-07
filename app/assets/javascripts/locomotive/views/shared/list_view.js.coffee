Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.ListView extends Backbone.View

  tagName: 'div'

  _item_views = []

  initialize: ->
    _.bindAll(@, 'insert_item', 'remove_item')
    @collection.bind('add', @insert_item)
    @collection.bind('remove', @remove_item)

  template: ->
    # please overide template

  item_view_class: ->
    # please overide item_view_class

  render: ->
    $(@el).html(@template()())

    @render_items()

    return @

  render_items: ->
    if @collection.length == 0
      @$('.no-items').show()
    else
      @collection.each (item) =>
        @insert_item(item)

  insert_item: (item) ->
    klass = @item_view_class()
    view = new klass model: item, parent_view: @

    (@_item_views ||= []).push(view)

    @$('.no-items').hide()
    @$('ul').append(view.render().el)

  remove_item: (item) ->
    @$('.no-items').show() if @collection.length == 0
    view = _.find @_item_views, (tmp) -> tmp.model == item
    view.remove() if view?

  remove: ->
    _.each @_item_views, (view) => view.remove()
    super



