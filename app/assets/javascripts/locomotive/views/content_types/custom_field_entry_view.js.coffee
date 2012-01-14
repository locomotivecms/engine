Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.CustomFieldEntryView extends Backbone.View

  tagName: 'li'

  className: 'custom-field'

  events:
    'click a.toggle': 'toggle'
    'click a.remove': 'remove'

  initialize: ->
    @model.bind 'change', (custom_field) =>
      @switch_to_type() if @model.hasChanged('type')

  render: ->
    $(@el).html(ich.custom_field_entry(@model.toJSON()))

    Backbone.ModelBinding.bind @, all: 'class'

    @make_fields_editable()

    @enable_behaviours()

    @switch_to_type()

    return @

  enable_behaviours: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()
    @render_select_options_view()

  switch_to_type: ->
    @$('li.input.extra').hide() # reset

    switch @model.get('type')
      when 'select'
        @$('li.input.select-options').show()
      when 'text'
        @$('li.input.text-formatting').show()

  render_select_options_view: ->
    @select_options_view = new Locomotive.Views.ContentTypes.SelectOptionsView
      model:      @model
      collection: @model.get('select_options')

    @$('#content_type_contents_custom_field_select_options_input').append(@select_options_view.render().el)

  make_fields_editable: ->
    @$('span.label-input input[type=text], span.type-input select').editableField()

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