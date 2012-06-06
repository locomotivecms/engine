Locomotive.Views.InlineEditor ||= {}

#= require ./toolbar_view

class Locomotive.Views.InlineEditor.ApplicationView extends Backbone.View

  el: 'body'

  initialize: ->
    super

    @iframe = @$('#page iframe')

    _.bindAll(@, '_$')

    @toolbar_view = new Locomotive.Views.InlineEditor.ToolbarView(target: @iframe)

    @content_assets_picker_view = new Locomotive.Views.ContentAssets.PickerView(collection: new Locomotive.Models.ContentAssetsCollection())

  render: ->
    super

    @enable_iframe_autoheight()

    @toolbar_view.render()

    @content_assets_picker_view.render()

  enable_iframe_autoheight: ->
    iframe = @iframe

    iframe.load =>
      if @_$('meta[name=inline-editor]').size() > 0
        # bind the resize event. When the iFrame's size changes, update its height
        iframe_content = iframe.contents()
        iframe_content.resize ->
          elem = $(this)

          if elem.outerHeight(true) > iframe.outerHeight(true) # Resize the iFrame.
            iframe.css height: elem.outerHeight(true)

        # Resize the iFrame immediately.
        iframe_content.resize()
      else
        @toolbar_view.show_status('disabled', true).hide_editing_mode_block()

        # keep the user in the admin mode
        @enhance_iframe_links()

  set_page: (attributes) ->
    @page = new Locomotive.Models.Page(attributes)

    @toolbar_view.model = @page

    @enhance_iframe()

    @toolbar_view.refresh()

  enhance_iframe: ->
    _window = @iframe[0].contentWindow
    _window.Aloha.settings.locale = window.locale

    # set main window title
    window.document.title = _window.document.title

    # keep the user in the admin mode
    @enhance_iframe_links _window.Aloha.jQuery

    # notify the toolbar about changes
    _window.Aloha.bind 'aloha-editable-deactivated', (event, editable) =>
      @toolbar_view.notify editable.editable

  enhance_iframe_links: (_jQuery) ->

    toolbar_view = @toolbar_view
    _jQuery     ||= @_$

    _jQuery('a').each ->
      link  = _jQuery(this)
      url   = link.attr('href')
      if url? && url.indexOf('#') != 0 && /^(www|http)/.exec(url) == null && /(\/_edit)$/.exec(url) == null && /^\/sites\//.exec(url) == null
        url = '/index' if url == '/'

        unless url.indexOf('_edit') > 0
          if url.indexOf('?') > 0
            link.attr('href', url.replace('?', '/_edit?'))
          else
            link.attr('href', "#{url}/_edit")

        link.bind 'click', ->
          toolbar_view.show_status 'loading'
          window.history.pushState('Object', 'Title', link.attr('href').replace('_edit', '_admin'))

  unique_dialog_zindex: ->
    # returns the number of jQuery UI modals created in order to set a valid zIndex for each of them.
    # Each modal window should have a different zIndex, otherwise there will be conflicts between them.
    window.Locomotive.jQueryModals ||= 0

    1050 + window.Locomotive.jQueryModals++

  _$: (selector) ->
    $(selector, @iframe[0].contentWindow.document)

