Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.ListView extends Backbone.View

  el: '.pages-tree'

  render: ->
    @make_foldable()

    @make_sortable()

    @make_hoverable()

    return @

  make_foldable: ->
    self = @

    @$('ul .fold-unfold').each ->
      $toggler  = $(this)
      $children = $toggler.next('ul.leaves')

      # hide the folded nodes at startup
      $children.hide() if $toggler.hasClass('folded')

    .click (event) ->
      $toggler  = $(this)
      $node     = $toggler.parents('li.node')
      $children = $toggler.next('ul.leaves')

      if $toggler.hasClass('folded')
        $children.slideDown 'fast', ->
          $toggler.removeClass('folded').addClass('unfolded')
          $.cookie($node.attr('id'), 'unfolded', { path: window.Locomotive.mounted_on })
      else
        $children.slideUp 'fast', ->
          $toggler.removeClass('unfolded').addClass('folded')
          $.cookie($node.attr('id'), 'folded', { path: window.Locomotive.mounted_on })

  make_sortable: ->
    self = @

    @$('ul').sortable
      items:        '> li.page'
      handle:       '.draggable'
      axis:         'y'
      placeholder:  'sortable-placeholder'
      cursor:       'move'
      update: (event, ui)  ->
        self.call_sort $(@)
      stop: (event, ui) ->
        if $(@).hasClass('root')
          position = ui.item.index()
          $(@).sortable('cancel') if position == 0 || position >= $(@).find('> li').size() - 2

  make_hoverable: ->
    @$('a').hover ->
      $(@).prev('i.icon').addClass('on')
    , -> $(@).prev('i.icon').removeClass('on')

  call_sort: (folder) ->
    $.rails.ajax
      url:        folder.data('url')
      type:       'post'
      dataType:   'json'
      data:
        children: (_.map folder.sortable('toArray'), (el) -> el.replace('node-', ''))
        _method:  'put'
      success:    @.on_successful_sort
      error:      @.on_failed_sort

  on_successful_sort: (data, status, xhr) ->
    Locomotive.notify decodeURIComponent($.parseJSON(xhr.getResponseHeader('X-Message'))), 'success'

    # maybe some components depends on it (ex: refreshing a menu if live editing is on)
    PubSub.publish 'pages.sorted'

  on_failed_sort: (data, status, xhr) ->
    Locomotive.notify decodeURIComponent($.parseJSON(xhr.getResponseHeader('X-Message'))), 'error'

