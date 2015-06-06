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
    # @replace_drawer_view()

    $('iframe').load => @on_iframe_load(_)

  on_iframe_load: ->
    $target_window = $('iframe')[0].contentWindow
    $iframe = $($target_window.document)

    target_path = $target_window.location.href
    editable_elements_path = $iframe.find('meta[name=locomotive-editable-elements-path]').attr('content')

    if editable_elements_path?
      unless editable_elements_path == window.location.pathname
        history.pushState(null, null, editable_elements_path)

        # @replace_drawer_view(editable_elements_path)

    else
      alert 'TODO: not a page of this site. Can not be edited'

  # replace_drawer_view: (url) ->
  #   drawer_view = window.application_view.drawer_view
  #   drawer_view.replace(url: url, view_klass: Locomotive.Views.EditableElements.EditView)
