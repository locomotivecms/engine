Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.IndexView extends Backbone.View

  el: '#content'

  events:
    'click .box a.remove': 'remove_asset'

  render: ->
    return @

  remove_asset: (event) ->
    event.stopPropagation() & event.preventDefault()

    link = $(event.target)

    $.rails.ajax
      url:        link.attr('href')
      type:       'post'
      dataType:   'json'
      data:
        _method:  'delete'
      success:    @on_successful_delete
      error:      @on_failed_delete

  on_successful_delete: (data, status, xhr) ->
    console.log('youpi')
    $.growl('success', xhr.getResponseHeader('X-Message'))

  on_failed_delete: (data, status, xhr) ->
    $.growl('error', xhr.getResponseHeader('X-Message'))

