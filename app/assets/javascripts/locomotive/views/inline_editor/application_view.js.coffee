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
    iframe = @iframe
    iframe.load =>
      # add js / css
      doc = iframe[0].contentWindow.document
      window.addStylesheet doc, '/assets/locomotive/aloha/css/aloha.css'
      window.addJavascript doc, '/assets/locomotive/utils/aloha_settings.js'
      window.addJavascript doc, '/assets/locomotive/aloha/lib/aloha.js',
        'data-aloha-plugins': 'common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste'
        onload: =>
          @toolbar_view.enable()
          iframe[0].contentWindow.Aloha.bind 'aloha-editable-deactivated', (event, editable) =>
            @toolbar_view.change_editable_element editable.editable

      # bind the resize event. When the iFrame's size changes, update its height
      iframe_content = iframe.contents().find('body')
      iframe_content.resize ->
        elem = $(this)

        if elem.outerHeight(true) > $('body').outerHeight(true) # Resize the iFrame.
          iframe.css height: elem.outerHeight(true)

      # Resize the iFrame immediately.
      iframe_content.resize()