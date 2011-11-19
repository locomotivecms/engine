Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Backbone.View

  tag: 'div'

  number_items_per_row: 4

  _item_views: []

  initialize: ->
    _.bindAll(@, 'add_assets', 'add_asset', 'remove_asset')
    @collection.bind('reset', @add_assets)
    @collection.bind('add', @add_asset)
    @collection.bind('remove', @remove_asset)

  render: ->
    @_reset()

    $(@el).html(ich.content_asset_picker())

    @collection.fetch()

    return @

  create_dialog: ->
    @dialog = $(@el).dialog
      modal:    true
      width:    650,
      create: =>
        $('.ui-widget-overlay').bind 'click', => @close()

        @$('h2').appendTo($(@el).prev())
        actions = @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        actions.find('#close-link').click (event) => @close(event)

      open: =>
        actions = $(@el).parent().find('.ui-dialog-buttonpane')
        link    = actions.find('#upload-link')
        el      = actions.find('input[type=file]')

        window.ImageUploadify.build el, # TODO: ImageUploadify => DefaultUploadify. Put this in method
          url:        link.attr('href')
          data_name:  el.attr('name')
          height:     link.outerHeight()
          width:      link.outerWidth()
          file_ext:   '*.png;*.gif;*.jpg;*.jpeg;*.pdf;*.doc;*.docx;*.xls;*.xlsx;*.txt'
          success:    (model) => @collection.add(model)
          error:      (msg)   => @shake()

        actions.find('.upload-button-wrapper').hover(
          => link.addClass('hover'),
          => link.removeClass('hover')
        )

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
    collection.each @add_asset

    @_refresh()

    setTimeout (=> @create_dialog()), 30 # disable flickering

  add_asset: (asset) ->
    view = new Locomotive.Views.ContentAssets.PickerItemView model: asset, parent: @

    (@_item_views ||= []).push(view)
    @$('ul.list .clear').before(view.render().el)

    @_refresh()

  remove_asset: (asset) ->
    view = _.find @_item_views, (tmp) -> tmp.model == asset
    view.remove() if view?
    @_refresh()
    @center()

  _refresh: ->
    if @collection.length == 0
      @$('ul.list').hide() & @$('p.no-items').show()
    else
      @$('p.no-items').hide() & @$('ul.list').show()
      self = @
      @$('ul.list li.asset').each (index) ->
        if (index + 1) % self.number_items_per_row == 0
          $(@).addClass('last')
        else
          $(@).removeClass('last')

    @center() if @dialog?

  _reset: ->
    _.each @_item_views || [], (view) -> view.remove()
    $('.ui-widget-overlay').unbind 'click'
    @$('.actions input[type=file]').remove()
    @dialog.dialog('destroy') if @dialog?