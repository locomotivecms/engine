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
    _window = @_window()

    _window.Aloha.settings.locale = window.locale

    # set main window title
    window.document.title = _window.document.title

    # allow to hit the refresh button and still stay on the same page
    window.history.replaceState('OBJECT', 'TITLE', _window.location.href.replace('_edit', '_admin'))

    # only but dirty way to handle back buttons with webkit.
    if $.browser.webkit
      window.history.pushState('OBJECT', 'TITLE', _window.location.href.replace('_edit', '_admin'))

    # keep the user in the admin mode
    @enhance_iframe_links _window.Aloha.jQuery

    # notify the toolbar about changes
    _window.Aloha.bind 'aloha-editable-deactivated', (event, editable) =>
      @toolbar_view.notify editable.editable

  enhance_iframe_links: (_jQuery) ->
    toolbar_view  = @toolbar_view
    _jQuery       ||= @_$
    _window       = @_window()

    _jQuery('a[class!="ui-tabs-anchor"]').live 'click', (event) ->
      link  = _jQuery(this)
      url   = link.attr('href')

      if url? && url.indexOf('#') != 0 && /^(www|http)/.exec(url) == null && /(\/_edit)$/.exec(url) == null && /^\/sites\//.exec(url) == null
        # change the url only if aloha is enabled
        unless link.parents('div.editable-long-text, div.editable-short-text').hasClass('aloha-editable')

          url = '/index' if url == '/'

          unless url.indexOf('_edit') > 0
            if url.indexOf('?') > 0
              url = url.replace('?', '/_edit?')
            else
              url = "#{url}/_edit"

          # let the editor know that we are redirecting her/him to the target page
          toolbar_view.show_status 'loading'

          # redirection now !
          link.attr('href', url)
      else
        # force the opening of a new window because we are in an iframe (security)
        event.preventDefault()
        window.open url

  unique_dialog_zindex: ->
    # returns the number of jQuery UI modals created in order to set a valid zIndex for each of them.
    # Each modal window should have a different zIndex, otherwise there will be conflicts between them.
    window.Locomotive.jQueryModals ||= 0

    1050 + window.Locomotive.jQueryModals++

  _window: ->
     @iframe[0].contentWindow

  _$: (selector) ->
    $(selector, @_window().document)

