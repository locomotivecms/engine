Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.ListView extends Backbone.View

  initialize: ->
    @sort_url = $(@el).data('sort-url')

  render: ->
    @make_sortable() if @sort_url?

  make_sortable: ->
    self = @

    $(@el).sortable
      items:        '> .item'
      handle:       '.draggable'
      axis:         'y'
      placeholder:  'sortable-placeholder'
      cursor:       'move'
      start:        (e, ui) ->
        ui.placeholder.html('<div class="inner">&nbsp;</div>')
      update: (event, ui)  ->
        self.call_sort(ui)

  call_sort: ->
    $.rails.ajax
      url:        @sort_url
      type:       'post'
      dataType:   'json'
      data:
        entries:  _.map $(@el).find('> .item'), (el) -> $(el).data('id')
        _method:  'put'
      success:    @.on_successful_sort
      error:      @.on_failed_sort

  on_successful_sort: (data, status, xhr) ->
    # $.growl('success', decodeURIComponent $.parseJSON xhr.getResponseHeader('X-Message'))

  on_failed_sort: (data, status, xhr) ->
    # $.growl('error', decodeURIComponent $.parseJSON xhr.getResponseHeader('X-Message'))
