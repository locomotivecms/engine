Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.IndexView extends Backbone.View

  el: '#content'

  # events:
  #   'click .box a.remove': 'remove_asset'

  # initialize: ->

  render: ->
    @render_snippets()

    return @

  render_snippets: ->
    @snippets_view = new Locomotive.Views.Snippets.ListView collection: @options.snippets

    @$('#snippets-anchor').replaceWith(@snippets_view.render().el)

  remove: ->
    @snippets_view.remove()
    super

  # remove_asset: (event) ->
  #   event.stopPropagation() & event.preventDefault()
  #
  #   link = $(event.target)
  #
  #   if confirm(link.attr('data-confirm'))
  #     $.rails.ajax
  #       url:        link.attr('href')
  #       type:       'post'
  #       dataType:   'json'
  #       data:
  #         _method:  'delete'
  #       success:    (data, status, xhr) => @on_successful_delete(link, xhr)
  #       error:      @on_failed_delete
  #
  #
  # on_successful_delete: (link, xhr) ->
  #   link.parents('')
  #   $.growl('success', xhr.getResponseHeader('X-Message'))
  #
  # on_failed_delete: (data, status, xhr) ->
  #   $.growl('error', xhr.getResponseHeader('X-Message'))

