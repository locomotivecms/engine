#= require ./file_view

Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.ImageView extends Locomotive.Views.Inputs.Rte.FileView

  initialize: ->
    super()
    @$link        = @$('a[data-wysihtml5-command=insertImage]')
    @$popover     = @$link.next('.image-dialog-content')

  attach_editor: ->
    command = @editor.toolbar.commandMapping['insertImage:null']
    command.dialog = @
