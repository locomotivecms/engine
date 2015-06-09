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
    @edit_view    = new Locomotive.Views.EditableElements.EditView()
    @pubsub_token = PubSub.subscribe('inputs.image_changed', @refresh_image)

    $('iframe').load => @on_iframe_load()

  render: ->
    super()
    @edit_view.render()

  refresh_image: (msg, data) ->
    $parent_view  = $(data.view.el).parent()
    element_id    = $parent_view.find('input[name*="[humanized_id]"]').val()
    old_image_url = $parent_view.find('input[name*="[content]"]').val()
    image_url     = data.url || old_image_url
    class_name    = "locomotive-#{element_id}"

    $iframe_document = $($('iframe')[0].contentWindow.document)

    # look for elements pointing to the editable file
    if ($elements = $iframe_document.find(".#{class_name}")).size() > 0
      $elements.each ->
        if this.nodeName == 'IMG'
          $(this).attr('src', image_url)
        else
          $(this).css("background-image", "url('" + image_url + "')")
    else
      # looking for DIVs with background-url property matching the previous image url
      $el = $iframe_document.find("*[style*='#{old_image_url}']").addClass(class_name)
      $el.css("background-image", "url('" + image_url + "')")

      # looking for IMGs with src attribute matching the previous image url
      $el = $iframe_document.find("img[src*='#{old_image_url}']").addClass(class_name)
      $el.attr('src', image_url)

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

  remove: ->
    super
    @edit_view.remove()
    PubSub.unsubscribe(@pubsub_token)
