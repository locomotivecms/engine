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

    # create the highlighter view
    @views = [new Locomotive.Views.EditableElements.TextHighLighterView(el: @el, button_labels: @options.button_labels)]

  render: ->
    # render the highlighter view
    _.invoke @views, 'render'

  scroll_to_block: (msg, data) ->
    @_scroll_to @$("span.locomotive-block-anchor[data-element-id=\"#{data.name}\"]")

  scroll_to_element: (msg, data) ->
    @_scroll_to @$("span.locomotive-editable-text[data-element-id=\"#{data.element_id}\"]")

  _scroll_to: (element) ->
    return false if element.size() == 0
    $(@el).animate({ scrollTop: element.offset().top }, 500)

  refresh_all: (msg, data) ->
    @options.parent_view.reload()

  refresh_text: (msg, data) ->
    @refresh_elements 'text', data.view, ($elements) ->
      $elements.each -> $(this).html(data.content)

  refresh_image_on_remove: (msg, data) ->
    data.url = $(data.view.el).parent().find('input[name*="[default_source_url]"]').val()
    @refresh_image(msg, data)

  refresh_image: (msg, data) ->
    @refresh_elements 'image', data.view, ($elements, element_id) =>
      current_image_url = data.view.$('input[name*="[content]"]').val()
      image_url         = data.url || current_image_url

      if $elements.size() > 0
        @replace_images($elements, image_url)
      else
        @replace_images_identified_by_url(current_image_url, image_url, element_id)

  refresh_elements: (type, view, callback) ->
    $form_view  = $(view.el).parent()
    element_id  = $form_view.find('input[name*="[id]"]').val()

    callback($(@el).find("*[data-element-id=#{element_id}]"), element_id)

  replace_images: (images, new_image_url) ->
    images.each ->
      if this.nodeName == 'IMG'
        $(this).attr('src', new_image_url)
      else
        $(this).css("background-image", "url('" + new_image_url + "')")

  replace_images_identified_by_url: (current_image_url, new_image_url, element_id) ->
    # looking for DIVs with background-url property matching the previous image url
    $el = $(@el).find("*[style*='#{current_image_url}']").attr('data-element-id', element_id)
    $el.css("background-image", "url('" + new_image_url + "')")

    # looking for IMGs with src attribute matching the previous image url
    $el = $(@el).find("img[src*='#{current_image_url}']").attr('data-element-id', element_id)
    $el.attr('src', new_image_url)

  remove: ->
    super()
    _.each @tokens, (token) -> PubSub.unsubscribe(token)
    _.invoke @views, 'remove'
