Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.IndexView extends Backbone.View

  el: '.wrapper'

  events:
    'click .expand-button': 'expand_preview'
    'click .close-button':  'shrink_preview'

  expand_preview: (event) ->
    $('body').addClass('full-width-preview')

  shrink_preview: (event) ->
    $('body').removeClass('full-width-preview')

  initialize: ->
    @edit_view = new Locomotive.Views.EditableElements.EditView()

    $('iframe').load => @on_iframe_load(_)

  render: ->
    super()
    @edit_view.render()

  on_iframe_load: ->
    $target_window = $('iframe')[0].contentWindow
    $iframe = $($target_window.document)

    target_path = $target_window.location.href
    editable_elements_path = $iframe.find('meta[name=locomotive-editable-elements-path]').attr('content')

    if editable_elements_path?
      unless editable_elements_path == window.location.pathname
        history.pushState(null, null, editable_elements_path)

        @replace_edit_view(editable_elements_path)

    else
      alert 'TODO: not a page of this site. Can not be edited'

  replace_edit_view: (url) ->
    $(@edit_view.el).load url, =>
      @edit_view.remove()
      @edit_view = new Locomotive.Views.EditableElements.EditView()
      @edit_view.render()
