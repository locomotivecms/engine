Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.TextHighLighterView extends Backbone.View

  events:
    'mouseenter .locomotive-editable-text':         'show'
    'mouseleave .locomotive-editable-text':         'hide'
    'mouseenter .locomotive-highlighter-text':      'clear_hiding_timeout'
    'mouseleave .locomotive-highlighter-text':      'hide'
    'click      #locomotive-highlighter-actions a': 'edit'

  initialize: ->
    @build()

  render: ->
    @adjust_height()

  edit: (event) ->
    event.stopPropagation() & event.preventDefault()

    @hide()

    PubSub.publish 'editable_elements.highlighted_text', element_id: @highlighted_element_id

  build: ->
    actions_html  = '<div id="locomotive-highlighter-actions" class="locomotive-highlighter-text"><a href="#"><i class="locomotive-fa locomotive-fa-pencil"></i>' + @localize('edit') + '</a></div>'
    bar_html      = '<div id="locomotive-highlighter-bar" class="locomotive-highlighter-text"></div>'

    $(@el).append(actions_html)
    $(@el).append(bar_html)

    @$('.locomotive-highlighter-text').hide()

  show: (event) ->
    $highliter  = @$('.locomotive-highlighter-text')
    offset      = @find_element_offset(event)

    @clear_hiding_timeout()

    # show actions
    $action = $highliter.first().show()
    $action.offset('top': parseInt(offset.top) - 32, 'left': parseInt(offset.left) - 10)
    $action.width(offset.width).show()

    # show bar
    $bar = $highliter.last().show()
    $bar.offset('top': parseInt(offset.top), 'left': parseInt(offset.left) - 10)
    $bar.height(offset.height).show()

  hide: (event) ->
    @hiding_timeout = setTimeout ( =>
      @_hide()
    ), 600

  _hide: ->
    @$('.locomotive-highlighter-text').hide()

  clear_hiding_timeout: ->
    # stop the process of hiding the selectors
    clearTimeout(@hiding_timeout) if @hiding_timeout?

  adjust_height: ->
    @$('.locomotive-editable-text').each ->
      height = $(this).height()
      height = $(this).css('display', 'block').height() if height == 0

  find_element_offset: (event) ->
    $el = $(event.target)
    $el = $el.parents('.locomotive-editable-text') unless $el.hasClass('locomotive-editable-text')

    # keep track of the ID of the highlighted text
    @highlighted_element_id = $el.data('element-id')

    _.extend $el.offset(), height: $el.height(), width: $el.width()

  localize: (key) ->
    @options.button_labels[key]

  remove: ->
    super
    clearTimeout(@hiding_timeout) if @hiding_timeout?
