Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.ImagePickerView extends Backbone.View

  tag: 'div'

  events:
    'click ul.list a':  'select_asset'

  initialize: ->
    _.bindAll(@, 'add_assets', 'add_asset')
    @collection.bind('reset', @add_assets)

  render: ->
    @_reset()

    $(@el).html(ich.theme_image_picker())

    @collection.fetch data: { content_type: 'image' }

    return @

  create_dialog: ->
    @dialog = $(@el).dialog
      modal:    true
      width:    600,
      create: =>
        $('.ui-widget-overlay').bind 'click', => @close()

        @$('h2').appendTo($(@el).prev())
        actions = @$('.actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        actions.find('#close-link').click (event) => @close(event)

      open: =>
        actions = $(@el).parent().find('.ui-dialog-buttonpane')
        link    = actions.find('#upload-link')
        el      = actions.find('input[type=file]')

        window.ImageUploadify.build el,
          url:        link.attr('href')
          data_name:  el.attr('name')
          height:     link.outerHeight()
          width:      link.outerWidth()
          success:    (model) => @add_asset(new Locomotive.Models.ThemeAsset(model))
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

  select_asset: (event) ->
    event.stopPropagation() & event.preventDefault()
    if @options.on_select
      @options.on_select($(event.target).html())

  add_assets: (collection) ->
    if collection.length == 0
      @$('p.no-items').show()
    else
      @$('ul.list').show()
      collection.each @add_asset

    setTimeout (=> @create_dialog()), 30 # disable flickering

  add_asset: (asset) ->
    @$('ul.list').append(ich.theme_asset(asset.toJSON()))
    @center() if @editor

  _reset: ->
    $('.ui-widget-overlay').unbind 'click'
    @$('.actions input[type=file]').remove()
    @dialog.dialog('destroy') if @dialog?