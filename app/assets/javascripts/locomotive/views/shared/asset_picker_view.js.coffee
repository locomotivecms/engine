Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.AssetPickerView extends Backbone.View

  tag: 'div'

  initialize: ->
    _.bindAll(@, 'add_assets', 'add_asset', 'remove_asset')
    @collection.bind('reset', @add_assets)
    @collection.bind('add', @add_asset)
    @collection.bind('remove', @remove_asset)

  render: ->
    @_reset()

    $(@el).html(@template()())

    @fetch_assets()

    return @

  template: ->
    # please overide template

  fetch_assets: ->
    # please overide fetch_assets

  build_uploader: (el, link) ->
    # please overide build_uploader

  create_dialog: ->
    @dialog = $(@el).dialog
      modal:    true
      zIndex:   998
      width:    650,
      create: (event, ui) =>
        $('.ui-widget-overlay').bind 'click', => @close()

        $(@el).prev().find('.ui-dialog-title').html(@$('h2').html())
        @$('h2').remove()
        actions = @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        actions.find('#close-link').click (event) => @close(event)

      open: (event, ui, extra) =>
        actions = $(@el).parent().find('.ui-dialog-buttonpane')
        el      = actions.find('input[type=file]')
        link    = actions.find('#upload-link')

        @build_uploader(el, link)

    @open()

  open: ->
    $(@el).dialog('open')

  close: (event) ->
    event.stopPropagation() & event.preventDefault() if event?
    $(@el).dialog('close')

  shake: ->
    $(@el).parents('.ui-dialog').effect('shake', { times: 4 }, 100)

  center: ->
    $(@el).dialog('option', 'position', 'center')

  add_assets: (collection) ->
    collection.each (asset) =>
      @add_asset(asset, true)

    @_refresh()

    setTimeout (=> @create_dialog()), 30 # disable flickering

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
    $('.ui-widget-overlay').unbind 'click'
    @$('.actions input[type=file]').remove()
    @dialog.dialog('destroy') if @dialog?