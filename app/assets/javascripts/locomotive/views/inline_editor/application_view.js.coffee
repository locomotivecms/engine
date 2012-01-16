Locomotive.Views.InlinEditor ||= {}

#= require ./toolbar_view

class Locomotive.Views.InlinEditor.ApplicationView extends Backbone.View

  el: 'body'

  initialize: ->
    super

    @iframe = @$('#page iframe')

    @toolbar_view = new Locomotive.Views.InlinEditor.ToolbarView(target: @iframe)

  render: ->
    super

    @decorate_iframe()

  set_page: (attributes) ->
    @page = new Locomotive.Models.Page(attributes)
    window.foo = @page

    @toolbar_view.model = @page

    @$('#toolbar .inner').html(@toolbar_view.refresh().render().el)

  decorate_iframe: ->
    console.log('decorating iframe')

    iframe = @iframe
    iframe.load =>
      # add js / css
      doc = iframe[0].contentWindow.document
      window.addJavascript doc, '/assets/locomotive/aloha/lib/aloha.js',
        'data-aloha-plugins': 'common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste'
      window.addStylesheet doc, '/assets/locomotive/aloha/css/aloha.css'

      # bind the resize event. When the iFrame's size changes, update its height
      iframe_content = iframe.contents().find('body')
      iframe_content.resize ->
        elem = $(this)

        if elem.outerHeight(true) > $('body').outerHeight(true) # Resize the iFrame.
          iframe.css height: elem.outerHeight(true)

      # Resize the iFrame immediately.
      iframe_content.resize()

  # render: ->
  #   super
  #
  #   console.log('rendering')
  #
  #   @enable_iframe_auto_height()
  #
  #   @foo()
  #
  #   @toolbar_view = new Locomotive.Views.
  #
  # set_page: (attributes) ->
  #   @page = new Locomotive.Models.Page(attributes)
  #
  #   window.foo = @page
  #
  #   @$('#toolbar .inner').html(ich.toolbar(@page.toJSON()))
  #
  # enable_iframe_auto_height: ->
  #   console.log('decorating iframe')
  #
  #   console.log(@$('#page iframe html'))
  #
  #   # @$('#page iframe').iframeAutoHeight
  #   #   debug: true
  #   #   callback: (callbackObject) =>
  #   #     $('body').css('overflow': 'visible')
  #
  #   iframe = @$('#page iframe')
  #   iframe.load =>
  #     iframe_content = iframe.contents().find('body')
  #
  #     # Bind the resize event. When the iframe's size changes, update its height as
  #     # well as the corresponding info div.
  #     iframe_content.resize ->
  #       elem = $(this)
  #
  #       # Resize the IFrame.
  #       if elem.outerHeight(true) > $('body').outerHeight(true)
  #         iframe.css height: elem.outerHeight(true)
  #
  #       # Update the info div width and height.
  #       # $('#iframe-info').text( 'IFRAME width: ' + elem.width() + ', height: ' + elem.height() );
  #
  #     # Resize the Iframe and update the info div immediately.
  #     iframe_content.resize()
  #
  # foo: ->
  #   @$('#page iframe').load =>
  #     # console.log 'iframe loaded'
  #     doc = @$('#page iframe')[0].contentWindow.document
  #
  #     script = doc.createElement('script')
  #     script.type = 'text/javascript'
  #     script.src = '/assets/locomotive/aloha/lib/aloha.js'
  #     script.setAttribute('data-aloha-plugins', 'common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste')
  #     doc.body.appendChild(script)
  #
  #     stylesheet = doc.createElement('link')
  #     stylesheet.style = 'text/css'
  #     stylesheet.href = '/assets/locomotive/aloha/css/aloha.css'
  #     stylesheet.media = 'screen'
  #     stylesheet.rel = 'stylesheet'
  #     doc.head.appendChild(stylesheet)
  #
  #     # <link href="/assets/locomotive/aloha/css/aloha.css" media="screen" rel="stylesheet" type="text/css" />
  #     # {{ '/assets/locomotive/aloha/css/aloha.css' | stylesheet_tag }}
  #
  #     # $("body", doc).append(script)
  #
  #     # $('body', doc).append('<script src="assets/locomotive/aloha/lib/aloha.js" data-aloha-plugins="common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste,common/block"></script>')
  #
  #     # <script src="/assets/locomotive/aloha/lib/aloha.js" data-aloha-plugins="common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste,common/block"></script>
  #     # $('body', doc).append('<p>Hello world</p>');
  #
  #
  # # register_page_content: (iframe) ->
  # #
  # #
  # #   console.log 'he he'
  #
  #
  #
