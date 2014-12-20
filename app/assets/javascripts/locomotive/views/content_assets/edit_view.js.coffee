Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.EditView extends Backbone.View

  events:
    'click .apply-btn':           'apply'
    'click .resize-btn':          'toggle_resize_modal'

  initialize: ->
    _.bindAll(@, 'change_size', 'apply_resizing')
    super

  render: ->
    @width = parseInt(@$('.image-container').data('width'))
    @height = parseInt(@$('.image-container').data('height'))
    @ratio = @width / @height

    @create_cropper()
    @create_resize_popover()

  create_cropper: ->
    @$cropper = @$(".image-container > img")

    @set_cropper_height()
    @$cropper.cropper()

  create_resize_popover: ->
    @$link    = @$('.resize-btn')
    @$content = @$('.resize-form').show()

    @$content.find('input').on 'keyup', @change_size
    @$content.find('.apply-resizing-btn').on 'click', @apply_resizing

    @$link.popover
      container:  '.main'
      placement:  'top'
      content:    @$content
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

  toggle_resize_modal: (event) ->
    state = if @resize_modal_opened then 'hide' else 'show'
    @$link.popover(state)
    @resize_modal_opened = !@resize_modal_opened

  change_size: (event) ->
    $input  = $(event.target)
    value   = parseInt($input.val())
    value   = 100 if _.isNaN(value)

    # make sure the value is an integer
    $input.val(value)

    if $input.attr('name') == 'width'
      _value = Math.round(value / @ratio)
      @$content.find('input[name=height]').val(_value)
    else
      _value = Math.round(value * @ratio)
      @$content.find('input[name=width]').val(_value)

  apply_resizing: (event) ->
    event.stopPropagation() & event.preventDefault()
    $btn = $(event.target).button('loading')

    width   = parseInt(@$content.find('input[name=width]').val())
    height  = parseInt(@$content.find('input[name=height]').val())

    window.resizeImage(@$cropper[0], width, height)
      .then (image) =>
        @width  = width
        @height = height
        @$cropper.cropper('replace', image.src)
        @set_cropper_height()
        $btn.button('reset')
        @toggle_resize_modal()

    # _.defer =>
    #   window.resizeImage @$cropper[0], width, height, (result) =>
    #     console.log('done')
    #     # @width  = width
    #     # @height = height
    #     # @$cropper.cropper('replace', result.src)
    #     # @set_cropper_height()
    #     # @toggle_resize_modal()
    #     # $btn.button('reset')


  apply: (event) ->
    event.stopPropagation() & event.preventDefault()

    data = @$(".image-container > img").cropper('getData')
    console.log data

  set_cropper_height: ->
    container_height = @$('.edit-assets-container').height()

    if @height < container_height
      @$('.image-container').css('max-height', @height)
    else
      @$('.image-container').css('max-height', 'inherit')

  remove: ->
    console.log '[EditView] remove'
    @$cropper.cropper('destroy')
    @$link.popover('destroy')
    super
