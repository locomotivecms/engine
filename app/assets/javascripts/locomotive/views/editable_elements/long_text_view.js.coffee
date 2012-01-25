#= require ./short_text_view

Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.LongTextView extends Locomotive.Views.EditableElements.ShortTextView

  tinymce_settings: ->
    window.Locomotive.tinyMCE.defaultSettings