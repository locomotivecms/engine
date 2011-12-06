Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.ListView extends Backbone.View

  tagName: 'div'

  className: 'box'

  _item_views = []

  initialize: ->
    _.bindAll(@, 'remove_item')
    @collection = new Locomotive.Models.SnippetsCollection(@options.collection)
    @collection.bind('remove', @remove_item)

  render: ->
    $(@el).html(ich.snippets_list())

    @render_items()

    return @

  render_items: ->
    if @collection.length == 0
      @$('.no-items').show()
    else
      @collection.each (snippet) =>
        @insert_item(snippet)

  insert_item: (snippet) ->
    view = new Locomotive.Views.Snippets.ItemView model: snippet, parent_view: @

    (@_item_views ||= []).push(view)

    @$('ul').append(view.render().el)

  remove_item: (snippet) ->
    @$('.no-items').show() if @collection.length == 0
    view = _.find @_item_views, (tmp) -> tmp.model == snippet
    view.remove() if view?

  remove: ->
    _.each @_item_views, (view) => view.remove()
    super



