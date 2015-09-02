#= require ./text_view

class Locomotive.Views.Inputs.MarkdownView extends Locomotive.Views.Inputs.TextView

  events: _.extend {}, Locomotive.Views.Inputs.TextView.prototype.events,
    'click a[data-markdown-command]': 'run_command'

  opened_picker: false

  initialize: ->
    super

    _.bindAll(@, 'insert_file')

    @$textarea  = @$('textarea.markdown')
    @editor     = CodeMirror.fromTextArea @$textarea[0],
      mode:         'markdown'
      tabMode:      'indent'
      lineWrapping: true

    @pubsub_token = PubSub.subscribe('file_picker.select', @insert_file)

  run_command: (event) ->
    $link   = $(event.target).closest('a')
    command = $link.data('markdown-command')

    switch command
      when 'bold'       then @apply_bold()
      when 'italic'     then @apply_italic()
      when 'insertFile' then @open_file_picker($link.data('url'))
      else
        console.log "[Markdown input] command not implemented: #{command}"
        return

    @content_change_with_markdown()

  apply_bold: ->
    text = @editor.getSelection()
    text = 'Some text' unless text? && text.length > 0
    @editor.replaceSelection "**#{text}**"

  apply_italic: ->
    text = @editor.getSelection()
    text = 'Some text' unless text? && text.length > 0
    @editor.replaceSelection "*#{text}*"

  insert_file: (msg, data) ->
    return unless data.parent_view.cid == @.cid

    text = @editor.getSelection()
    text = data.title if !text? || text.length == 0

    if data.image
      @editor.replaceSelection " ![#{text}](#{data.url}) "
    else
      @editor.replaceSelection " [#{text}](#{data.url}) "

    @content_change_with_markdown()
    @hide_file_picker()

  content_change_with_markdown: ->
    event = $.Event 'change', target: @$textarea
    @content_change(event)

  text_value: (textarea) ->
    kramed(@editor.getValue())

  open_file_picker: (url) ->
    if @opened_picker == false
      window.application_view.drawer_view.open(
        url,
        Locomotive.Views.ContentAssets.PickerView,
        { parent_view: @ })
      @opened_picker = true

  hide_file_picker: ->
    window.application_view.drawer_view.close()
    @opened_picker = false

  remove: ->
    PubSub.unsubscribe(@pubsub_token)
    super
