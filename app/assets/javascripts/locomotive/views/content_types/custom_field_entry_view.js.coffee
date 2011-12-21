Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.CustomFieldEntryView extends Backbone.View

  tagName: 'li'

  className: 'custom-field'

  events:
    'click a.toggle': 'toggle'
    'click a.remove': 'remove'

  render: ->
    $(@el).html(ich.custom_field_entry(@model.toJSON()))

    Backbone.ModelBinding.bind @, all: 'class'

    @$('span.label-input input[type=text], span.type-input select').editableField()

    return @

  toggle: (event) ->
    event.stopPropagation() & event.preventDefault()
    form = @$('ol')

    if form.is(':hidden')
      form.slideDown()
    else
      form.slideUp()

  show_error: (message) ->
    html = $("<span class=\"inline-errors\">#{message}</div>")
    @$('span.required-input').after(html)

  remove: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      @$('span.label-input input[type=text], span.type-input select').editableField('destroy')
      super()
      @options.parent_view.remove_entry(@model, @)