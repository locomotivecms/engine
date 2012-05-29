Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.AssetPickerView extends Backbone.View

  tag: 'div'

  initialize: ->
    _.bindAll(@, 'add_assets', 'add_asset', 'remove_asset')
    @collection.bind('reset', @add_assets)
    @collection.bind('add', @add_asset)
    @collection.bind('remove', @remove_asset)

  render: ->
    $(@el).html(@template()())

    @create_dialog()

    return @

  template: ->
    # please overide template

  fetch_assets: ->
    # please overide fetch_assets

  build_uploader: (el, link) ->
    # please overide build_uploader

  create_dialog: ->
    @dialog ||= $(@el).dialog
      autoOpen: false
      modal:    true
      zIndex:   window.application_view.unique_dialog_zindex()
      width:    650,
      create: (event, ui) =>
        $(@el).prev().find('.ui-dialog-title').html(@$('h2').html())
        @$('h2').remove()
        actions = @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        actions.find('#close-link').click (event) => @close(event)

        input = actions.find('input[type=file]')
        link  = actions.find('#upload-link')

        @build_uploader(input, link)

      open: (event, ui, extra) =>
        $(@el).dialog('overlayEl').bind 'click', => @close()

  open: ->
    $(@el).dialog('open')

  close: (event) ->
    event.stopPropagation() & event.preventDefault() if event?
    $(@el).dialog('overlayEl').unbind('click')
    $(@el).dialog('close')

  shake: ->
    $(@el).parents('.ui-dialog').effect('shake', { times: 4 }, 100)

  center: ->
    $(@el).dialog('option', 'position', 'center')

  add_assets: (collection) ->
    collection.each (asset) =>
      @add_asset(asset, true)

    @_refresh()

  add_asset: (asset, first) ->
    # please overide add_asset (the 'first' param is to know if it comes from the first collection fetch)

  remove_asset: (asset) ->
    # please overide remove_asset

  _move_to_last_asset: ->
    limit = @$('ul.list li.clear').position()
    @$('ul.list').animate(scrollTop: limit.top, 100) if limit?

  _refresh: ->
    if @collection.length == 0
      @$('ul.list').hide() & @$('p.no-items').show()
    else
      @$('p.no-items').hide() & @$('ul.list').show()
      @_on_refresh()

    @center() if @dialog?

  _on_refresh: ->

  _reset: ->
    # for nothing to do
