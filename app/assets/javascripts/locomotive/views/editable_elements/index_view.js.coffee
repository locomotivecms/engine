Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.IndexView extends Backbone.View

  el: '.wrapper'

  events:
    'click .content .expand-button': 'expand_preview'
    'click .content .close-button':  'shrink_preview'

  expand_preview: (event) ->
    $('body').addClass('full-width-preview')

  shrink_preview: (event) ->
    $('body').removeClass('full-width-preview')

  initialize: ->
    _.bindAll(@, 'refresh_elements', 'refresh_image', 'refresh_image_on_remove', 'refresh_text', 'reload_page')

    view_options = if $('body').hasClass('live-editing') then {} else { el: '.main' }

    @startup            = true
    @edit_view          = new Locomotive.Views.EditableElements.EditView(view_options)
    @pubsub_text_token  = PubSub.subscribe('inputs.text_changed', @refresh_text)

    @pubsub_image_changed_token = PubSub.subscribe('inputs.image_changed', @refresh_image)
    @pubsub_image_removed_token = PubSub.subscribe('inputs.image_removed', @refresh_image_on_remove)

    @pubsub_block_selected      = PubSub.subscribe('editable_elements.block_selected', @move_to_block)
    @pubsub_pages_sorted_token  = PubSub.subscribe('pages.sorted', @reload_page)

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

  reload_page: (event) ->
    $iframe = $('.preview iframe')
    $target_window = $iframe[0].contentWindow
    $iframe.attr('src', @preview_url)

  move_to_block: (msg, data) ->
    $iframe_document = $($('iframe')[0].contentWindow.document)
    $anchor = $iframe_document.find("span.locomotive-block-anchor[data-element-id=\"#{data.name}\"]")

    return false if $anchor.size() == 0

    $iframe_document.find('html, body').animate
      scrollTop: $anchor.offset().top
    , 500

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

    # highlights regions so that users can see which text/image can be edited
    @highlight_editable_elements($($target_window.document))

    if editable_elements_path? && @startup == false
      History.replaceState({ live_editing: true, url: @preview_url }, '', editable_elements_path)
      @replace_edit_view(editable_elements_path)
    else
      @startup = false

  # TODO: create a custom backbone view for the iframe
  highlight_editable_elements: (iframe_document) ->
    # TODO: mouseexit?
    iframe_document.on 'mouseenter', '.locomotive-editable-text', (event) =>
      $el = $(event.target).closest('.locomotive-editable-text')

      if $el.size() > 0
        offset  = $el.offset()

        # TODO: make sure the selector doesn't go off the screen
        $selector = @find_or_build_selector(iframe_document)
        $selector.offset(top: offset.top, left: offset.left - 10).show()

        height = $el.height()
        height = $el.css('display', 'block').height() if height == 0
        # another way:
        # height = _.reduce($el.find('>'), function(sum, el) { return sum + $(el).height() }, 0)

        $selector.height(height)
      else
        console.log 'is that possible?'
        console.log $el

  # TODO: move this method to the iframe view
  find_or_build_selector: (iframe_document) ->
    $selector = iframe_document.find('#locomotive-selector')

    return $selector if $selector.size() > 0

    iframe_document.find('body').append('<div id="locomotive-selector" style="position: absolute; top: 0px; left: 0px; display: block;border-left: 5px solid yellow;z-index:10000"><a href="#" style="position: relative; top: -37px; left: -10px; color: #fff; ' + @button_css() + '">Edit</a></div>')
    iframe_document.find('#locomotive-selector').hide()

  # TODO: refactor it
  button_css: ->
    "background-color: rgb(84, 185, 205);border-bottom-color: rgb(54, 163, 184);border-bottom-left-radius: 3px;border-bottom-right-radius: 3px;" +
    "background-image: none; border-bottom-style: solid; border-bottom-width: 2px; border-image-outset: 0px;" +
    "border-image-repeat: stretch; border-image-slice: 100%; border-image-source: none; border-image-width: 1;" +
    "border-left-color: rgb(54, 163, 184); border-left-style: solid; border-left-width: 0px; border-right-color: rgb(54, 163, 184);" +
    "border-right-style: solid; border-right-width: 0px; border-top-color: rgb(54, 163, 184); border-top-left-radius: 3px; border-top-right-radius: 3px;" +
    "border-top-style: solid;border-top-width: 0px;
      box-sizing: border-box;
      color: rgb(255, 255, 255);
      cursor: pointer;
      display: inline-block;
      font-family: 'Noto Sans', sans-serif;
      font-size: 12px;
      font-weight: normal;
      height: 30px;
      line-height: 18px;
      margin-bottom: 0px;
      margin-left: 5px;
      padding-bottom: 5px;
      padding-left: 10px;
      padding-right: 10px;
      padding-top: 5px;
      text-align: center;
      text-decoration: none;
      touch-action: manipulation;
      vertical-align: middle;
      white-space: nowrap;"

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
    PubSub.unsubscribe(@pubsub_pages_sorted_token)
    PubSub.unsubscribe(@pubsub_block_selected)
