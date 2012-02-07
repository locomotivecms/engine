Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.ListView extends Backbone.View

  el: '#pages-list'

  render: ->
    @make_foldable()

    @make_sortable()

    return @

  make_foldable: ->
    @$('ul.folder img.toggler').toggleMe()

  make_sortable: ->
    self = @

    @$('ul.folder').sortable
      handle: 'em'
      axis:   'y'
      update: (event, ui) -> self.call_sort $(@)

  call_sort: (folder) ->
    $.rails.ajax
      url:        folder.attr('data-url')
      type:       'post'
      dataType:   'json'
      data:
        children: (_.map folder.sortable('toArray'), (el) -> el.replace('item-', ''))
        _method:  'put'
      success:    @.on_successful_sort
      error:      @.on_failed_sort

  on_successful_sort: (data, status, xhr) ->
    $.growl('success', xhr.getResponseHeader('X-Message'))

  on_failed_sort: (data, status, xhr) ->
    $.growl('error', xhr.getResponseHeader('X-Message'))
