Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.CustomFieldEntryView extends Backbone.View

  tagName: 'li'

  className: 'custom-field'

  events:
    'click a.edit':   'toggle_form'
    'click a.remove': 'remove'

  render: ->
    $(@el).html(ich.custom_field_entry(@model.toJSON()))

    Backbone.ModelBinding.bind @, all: 'class'

    return @

  toggle_form: (event) ->
    event.stopPropagation() & event.preventDefault()
    form = @$('ol')

    if form.is(':hidden')
      form.slideDown()
    else
      form.slideUp()

  remove: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      # @$('input[type=text]').editableField('destroy')
      super()
      @options.parent_view.remove_entry(@model, @)