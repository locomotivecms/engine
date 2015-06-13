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
    @edit_view          = new Locomotive.Views.EditableElements.EditView()
    @pubsub_image_token = PubSub.subscribe('inputs.image_changed', @refresh_image)
    @pubsub_text_token  = PubSub.subscribe('inputs.text_changed', @refresh_text)

    $('.preview iframe').load (event) => @on_iframe_load(event)

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

  refresh_text: (msg, data) ->
    console.log(data)

    # TODO
    # 1. get page[editable_elements_attributes][1][humanized_id] => <block>_<slug>
    # 2. find the span element in the iframe matching the humanized_id
    # 3. Patch Steam to display that span element
    #     -> html
    #     -> css
    #     -> add wysihtml css file
    # 4. Update the element with the new content

  on_iframe_load: (event) ->
    $iframe = $('.preview iframe')
    $target_window = $iframe[0].contentWindow
    editable_elements_path = null

    # unable to display the iframe in the frame because it set 'X-Frame-Options' to 'SAMEORIGIN'
    try
      $iframe_document = $($target_window.document)
      editable_elements_path = $iframe_document.find('meta[name=locomotive-editable-elements-path]').attr('content')
    catch e
      # reload the iframe with the previous url and display an error message
      $iframe.attr('src', @preview_url)
      Locomotive.notify $iframe.data('redirection-error'), 'warning'
      return

    # store the url
    @preview_url = $('.preview iframe')[0].contentWindow.document.location.href

    if editable_elements_path?
      unless editable_elements_path == window.location.pathname
        history.pushState(null, null, editable_elements_path)

        @replace_edit_view(editable_elements_path)

  replace_edit_view: (url) ->
    $(@edit_view.el).load url, =>
      @edit_view.remove()
      @edit_view = new Locomotive.Views.EditableElements.EditView()
      @edit_view.render()

  remove: ->
    super
    @edit_view.remove()
    PubSub.unsubscribe(@pubsub_image_token)
    PubSub.unsubscribe(@pubsub_text_token)
