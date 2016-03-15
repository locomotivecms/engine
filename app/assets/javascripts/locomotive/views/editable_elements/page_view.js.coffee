Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.PageView extends Backbone.View

  initialize: ->
    _.bindAll(@, 'refresh_all', 'refresh_text', 'refresh_image', 'refresh_image_on_remove', 'scroll_to_block', 'scroll_to_element')

    # Global event subscriptions
    @tokens = [
      PubSub.subscribe 'editable_elements.block_selected',      @scroll_to_block
      PubSub.subscribe 'editable_elements.form_group_selected', @scroll_to_element
      PubSub.subscribe 'inputs.text_changed',                   @refresh_text,
      PubSub.subscribe 'inputs.image_changed',                  @refresh_image,
      PubSub.subscribe 'inputs.image_removed',                  @refresh_image_on_remove,
      PubSub.subscribe 'pages.sorted',                          @refresh_all
    ]

    # used to prefix links to inner pages with mounted_on
    @mounted_on = @$('meta[name=locomotive-mounted-on]').attr('content')

    # create the highlighter view
    @views = [new Locomotive.Views.EditableElements.TextHighLighterView(el: @$('body'), button_labels: @options.button_labels)]

  render: ->
    # render the highlighter view
    _.invoke @views, 'render'

  scroll_to_block: (msg, data) ->
    @_scroll_to @$("span.locomotive-block-anchor[data-element-id=\"#{data.name}\"]")

  scroll_to_element: (msg, data) ->
    @_scroll_to @$("span.locomotive-editable-text[data-element-id=\"#{data.element_id}\"]")

  _scroll_to: (element) ->
    return false if element.size() == 0
    @$('body').animate({ scrollTop: element.offset().top }, 500)

  each_elements: (view, callback) ->
    $form_view  = $(view.el).parent()
    element_id  = $form_view.find('input[name*="[id]"]').val()

    callback(@$("*[data-element-id=#{element_id}]"), element_id)

  refresh_all: (msg, data) ->
    @options.parent_view.reload()

  refresh_text: (msg, data) ->
    @each_elements data.view, ($elements) ->
      $elements.each -> $(this).html(data.content)

  refresh_image_on_remove: (msg, data) ->
    data.url = $(data.view.el).parent().find('input[name*="[default_source_url]"]').val()
    @refresh_image(msg, data)

  refresh_image: (msg, data) ->
    @each_elements data.view, ($elements, element_id) =>
      if $elements.size() == 0
        $elements = @find_and_reference_images_identified_by_url(data.view.path, element_id)

      return if $elements.size() == 0

      resize_format     = data.view.$('.row').data('resize-format')
      current_image_url = data.view.$('input[name*="[content]"]').val()
      image_url         = data.url || current_image_url

      # ask for a cropped/resized version of the image
      window.resize_image image_url, resize_format, (resized_image) =>
        @replace_images($elements, resized_image)

  replace_images: (images, new_image_url) ->
    images.each ->
      if this.nodeName == 'IMG'
        $(this).attr('src', new_image_url)
      else
        $(this).css("background-image", "url('" + new_image_url + "')")

  # retrieve all the images and background images by their editable path
  # and associate the element_id to them
  find_and_reference_images_identified_by_url: (path, element_id) ->
    @$("*[style*='#{path}'],img[src*='#{path}']").attr('data-element-id', element_id)

  remove: ->
    super()
    _.each @tokens, (token) -> PubSub.unsubscribe(token)
    _.invoke @views, 'remove'
