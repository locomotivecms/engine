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
    # do nothing

  begin_change_file: ->
    @$file.click()

  begin_choose_file: ->
    @$file.click()

  change_file: (event) ->
    text = if event.target.files then event.target.files[0].name else 'New file'
    @$new_file.html(text)

    # show new file, hide the current one
    @showEl(@$new_file) && @hideEl(@$current_file) && @hideEl(@$no_file)

    # only show the cancel button
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @hideEl(@$choose_btn) && @showEl(@$cancel_btn)

  cancel_new_file: (event) ->
    # hide the new file
    @hideEl(@$new_file)

    # reset the file input
    @$file.wrap('<form>').closest('form').get(0).reset()
    @$file.unwrap()

    $(@el).removeClass('mark-as-removed')

    # no more mark file as deleted
    @$remove_file.val('0')

    # hide the cancel button
    @hideEl(@$cancel_btn)

    if @persisted_file
      # show the current file
      @showEl(@$current_file)

      # display the change + delete buttons
      @showEl(@$change_btn) && @showEl(@$delete_btn)
    else
      # show no_file
      @showEl(@$no_file)

      # display the choose button
      @showEl(@$choose_btn)

  mark_file_as_deleted: (event) ->
    # set true (or 1) as value for the remove_<method> hidden field
    @$remove_file.val('1')

    # add the "mark-as-removed" class to the el
    $(@el).addClass('mark-as-removed')

    # hide the change / delete buttons, show the cancel button
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @showEl(@$cancel_btn)

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')
