Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.FileView extends Backbone.View

  events:
    'change input[type=file]':  'change_file'
    'click a.choose':           'begin_choose_file'
    'click a.change':           'begin_change_file'
    'click a.cancel':           'cancel_new_file'
    'click a.delete':           'mark_file_as_deleted'

  initialize: ->
    @$file          = @$('input[type=file]')
    @$remove_file   = @$('input[type=hidden]')
    @$current_file  = @$('.current-file')
    @$no_file       = @$('.no-file')
    @$new_file      = @$('.new-file')

    @$choose_btn    = @$('.buttons .choose')
    @$change_btn    = @$('.buttons .change')
    @$cancel_btn    = @$('.buttons .cancel')
    @$delete_btn    = @$('.buttons .delete')

    @persisted_file = @$('.row').data('persisted-file')

  render: ->
    # alert 'hello world'

  begin_change_file: ->
    console.log 'begin_change_file'

    @$file.click()

  begin_choose_file: ->
    console.log 'begin_choose_file'

    @$file.click()

  change_file: (event) ->
    console.log 'end_change_file'

    text = if event.target.files then event.target.files[0].name else 'New file'
    @$new_file.html(text)

    # show new file, hide the current one ✓
    @showEl(@$new_file) && @hideEl(@$current_file) && @hideEl(@$no_file)

    # only show the cancel button ✓
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @hideEl(@$choose_btn) && @showEl(@$cancel_btn)

  cancel_new_file: (event) ->
    console.log 'cancel_new_file'

    # hide the new file
    @hideEl(@$new_file)

    # reset the file input ✓
    @$file.wrap('<form>').closest('form').get(0).reset()
    @$file.unwrap()

    $(@el).removeClass('mark-as-removed')

    # no more mark file as deleted
    @$remove_file.val('0')

    # hide the cancel button
    @hideEl(@$cancel_btn)

    if @persisted_file
      # show the current file ✓
      @showEl(@$current_file)

      # display the change + delete buttons ✓
      @showEl(@$change_btn) && @showEl(@$delete_btn)
    else
      # show no_file
      @showEl(@$no_file)

      # display the choose button
      @showEl(@$choose_btn)

  mark_file_as_deleted: (event) ->
    console.log 'mark_file_as_deleted'

    # TODO:
    # set true (or 1) as value for the remove_<method> hidden field
    @$remove_file.val('1')

    # add the "mark-as-removed" class to the el
    $(@el).addClass('mark-as-removed')

    # hide the change / delete buttons, show the cancel button
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @showEl(@$cancel_btn)

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')

    # TODO CHANGE FILE
    # 1. hide current filename ✓
    # 2. display the new name ✓
    # 3. hide the change button ✓
    # 4. hide the trash button ✓
    # 5. display the cancel button ✓



  # events:
  #   'click a.change': 'toggle_change'
  #   'click a.delete': 'toggle_delete'

  # template: ->
  #   prefix = if @options.namespace? then "#{@options.namespace}_" else ''
  #   ich["#{prefix}#{@options.name}_file_input"]

  # render: ->
  #   url   = @model.get("#{@options.name}_url") || ''
  #   data  =
  #     filename: url.split('/').pop()
  #     url:      url

  #   $(@el).html(@template()(data))

  #   # only in HTML 5
  #   @$('input[type=file]').bind 'change', (event) =>
  #     input = $(event.target)[0]

  #     if input.files?
  #       name  = $(input).prop('name')
  #       hash  = {}
  #       hash[name.replace("#{@model.paramRoot}[", '').replace(/]$/, '')] = input.files[0]
  #       @model.set(hash)

  #   return @

  # refresh: ->
  #   @$('input[type=file]').unbind 'change'
  #   @states = { 'change': false, 'delete': false }
  #   @render()

  # reset: ->
  #   @model.set_attribute @options.name, null
  #   @model.set_attribute "#{@options.name}_url", null
  #   @refresh()

  # toggle_change: (event) ->
  #   @_toggle event, 'change',
  #     on_change: =>
  #       @$('a:first').hide() & @$('input[type=file]').show() & @$('a.delete').hide()
  #     on_cancel: =>
  #       @$('a:first').show() & @$('input[type=file]').hide() & @$('a.delete').show()

  # toggle_delete: (event) ->
  #   @_toggle event, 'delete',
  #     on_change: =>
  #       @$('a:first').addClass('deleted') & @$('a.change').hide()
  #       @$('input[type=hidden].remove-flag').val('1')
  #       @model.set_attribute("remove_#{@options.name}", true)
  #     on_cancel: =>
  #       @$('a:first').removeClass('deleted') & @$('a.change').show()
  #       @$('input[type=hidden].remove-flag').val('0')
  #       @model.set_attribute("remove_#{@options.name}", false)

  # _toggle: (event, state, options) ->
  #   event.stopPropagation() & event.preventDefault()

  #   button  = $(event.target)
  #   label   = button.data('alt-label')

  #   unless @states[state]
  #     options.on_change()
  #   else
  #     options.on_cancel()

  #   button.data('alt-label', button.html())

  #   button.html(label)

  #   @states[state] = !@states[state]

  # remove: ->
  #   @$('input[type=file]').unbind 'change'
  #   super
