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

    if @$('#toolbar .inner .toolbar-view').size() == 0
      @$('#toolbar .inner').html(@toolbar_view.render().el) # first time we render it
    else
      @toolbar_view.refresh()

  decorate_iframe: ->
    iframe = @iframe
    iframe.load =>
      # add js / css
      doc = iframe[0].contentWindow.document
      window.addStylesheet doc, '/assets/locomotive/aloha/css/aloha.css'
      window.addJavascript doc, '/assets/locomotive/utils/aloha_settings.js'
      window.addJavascript doc, '/assets/locomotive/aloha/lib/aloha.js',
        'data-aloha-plugins': 'common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste'
        onload: =>
          console.log('loading target iframe')

          # wake up the toolbar
          @toolbar_view.enable()

          # keep the user in the admin mode
          _$ = iframe[0].contentWindow.Aloha.jQuery
          _$('a').each ->
            link  = _$(this)
            url   = link.attr('href')
            if url != '#' && /^(www|http)/.exec(url) == null && /(\/_edit)$/.exec(url) == null
              url = '/index' if url == '/'
              if url.indexOf('?') > 0
                link.attr('href', url.replace('?', '/_edit?'))
              else
                link.attr('href', "#{url}/_edit")

              link.bind 'click', ->
                window.history.pushState('Object', 'Title', link.attr('href').replace('_edit', '_admin'))

          # notify the toolbar about changes
          iframe[0].contentWindow.Aloha.bind 'aloha-editable-deactivated', (event, editable) =>
            @toolbar_view.notify editable.editable

      # bind the resize event. When the iFrame's size changes, update its height
      iframe_content = iframe.contents().find('body')
      iframe_content.resize ->
        elem = $(this)

        if elem.outerHeight(true) > $('body').outerHeight(true) # Resize the iFrame.
          iframe.css height: elem.outerHeight(true)

      # Resize the iFrame immediately.
      iframe_content.resize()