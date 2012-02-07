Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.IndexView extends Backbone.View

  el: '#content'

  render: ->
    @make_sortable()

    return @

  make_sortable: ->
    self = @

    @$('ul#entries-list.sortable').sortable
      handle: 'span.handle'
      items:  'li.item'
      axis:   'y'
      update: (event, ui) -> self.call_sort $(@)

  call_sort: (folder) ->
    $.rails.ajax
      url:        folder.attr('data-url')
      type:       'post'
      dataType:   'json'
      data:
        entries: (_.map folder.sortable('toArray'), (el) -> el.replace('entry-', ''))
        _method:  'put'
      success:    @.on_successful_sort
      error:      @.on_failed_sort

  on_successful_sort: (data, status, xhr) ->
    $.growl('success', xhr.getResponseHeader('X-Message'))

  on_failed_sort: (data, status, xhr) ->
    $.growl('error', xhr.getResponseHeader('X-Message'))