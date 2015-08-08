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
    _.bindAll(@, 'refresh_elements', 'refresh_image', 'refresh_image_on_remove', 'refresh_text')

    view_options = if $('body').hasClass('live-editing') then {} else { el: '.main' }

    @startup            = true
    @edit_view          = new Locomotive.Views.EditableElements.EditView(view_options)
    @pubsub_text_token  = PubSub.subscribe('inputs.text_changed', @refresh_text)

    @pubsub_image_changed_token = PubSub.subscribe('inputs.image_changed', @refresh_image)
    @pubsub_image_removed_token = PubSub.subscribe('inputs.image_removed', @refresh_image_on_remove)

    $('.preview iframe').load (event) => @on_iframe_load(event)

  render: ->
    super()
    @edit_view.render()

  refresh_elements: (type, view, callback) ->
    $parent_view  = $(view.el).parent()
    element_id    = $parent_view.find('input[name*="[id]"]').val()

    $iframe_document = $($('iframe')[0].contentWindow.document)

    callback($iframe_document.find("*[data-element-id=#{element_id}]"), element_id, $iframe_document)

  refresh_image_on_remove: (msg, data) ->
    data.url = $(data.view.el).parent().find('input[name*="[default_source_url]"]').val()
    @refresh_image(msg, data)

  refresh_image: (msg, data) ->
    @refresh_elements 'image', data.view, ($elements, element_id, $iframe_document) ->
      current_image_url = data.view.$('input[name*="[content]"]').val()
      image_url         = data.url || current_image_url

      if $elements.size() > 0
        $elements.each ->
          if this.nodeName == 'IMG'
            $(this).attr('src', image_url)
          else
            $(this).css("background-image", "url('" + image_url + "')")
      else
        # looking for DIVs with background-url property matching the previous image url
        $el = $iframe_document.find("*[style*='#{current_image_url}']").attr('data-element-id', element_id)
        $el.css("background-image", "url('" + image_url + "')")

        # looking for IMGs with src attribute matching the previous image url
        $el = $iframe_document.find("img[src*='#{current_image_url}']").attr('data-element-id', element_id)
        $el.attr('src', image_url)

  refresh_text: (msg, data) ->
    @refresh_elements 'text', data.view, ($elements) ->
      $elements.each -> $(this).html(data.content)

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

    if editable_elements_path? && @startup == false
      History.replaceState({ live_editing: true, url: @preview_url }, '', editable_elements_path)
      @replace_edit_view(editable_elements_path)
    else
      @startup = false

  replace_edit_view: (url) ->
    $(@edit_view.el).load url, =>
      @edit_view.remove()
      @edit_view = new Locomotive.Views.EditableElements.EditView()
      @edit_view.render()

  remove: ->
    super

    @edit_view.remove()

    PubSub.unsubscribe(@pubsub_image_changed_token)
    PubSub.unsubscribe(@pubsub_image_removed_token)
    PubSub.unsubscribe(@pubsub_text_token)
