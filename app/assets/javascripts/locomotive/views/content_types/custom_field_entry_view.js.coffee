Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.CustomFieldEntryView extends Backbone.View

  tagName: 'li'

  className: 'custom-field'

  events:
    'click a.toggle': 'toggle'
    'click a.remove': 'remove'

  initialize: ->
    @inverse_of_list = @options.parent_view.options.inverse_of_list

    @model.bind 'change', (custom_field) =>
      @switch_to_type() if @model.hasChanged('type')
      @fetch_inverse_of_list() if @model.hasChanged('class_name') && @model.get('class_name')?

  render: ->
    $(@el).html(ich.custom_field_entry(@model.toJSON()))

    @fetch_inverse_of_list() unless @model.isNew()

    Backbone.ModelBinding.bind @, all: 'class'

    @make_fields_editable()

    @enable_behaviours()

    @switch_to_type()

    return @

  enable_behaviours: ->
    required_input = @$('.required-input input[type=checkbox]')
    required_input.checkToggle(on_label: required_input.attr('data-on-label'), off_label: required_input.attr('data-off-label'))
    @$('li.input.toggle input[type=checkbox]').checkToggle()
    @render_select_options_view()

  switch_to_type: ->
    @$('li.input.extra').hide() # reset

    switch @model.get('type')
      when 'select'
        @$('li.input.select-options').show()
      when 'text'
        @$('li.input.text-formatting').show()
      when 'belongs_to'
        @$('li.input.localized').hide()
        @$('li.input.class-name').show()
      when 'has_many', 'many_to_many'
        @$('li.input.localized').hide()
        @$('li.input.class-name').show()
        @$('li.input.inverse-of').show()
        @$('li.input.ui-enabled').show()

  fetch_inverse_of_list: ->
    @$('li.input.inverse-of select option').remove()

    list = @inverse_of_list[@model.get('type')] || []

    _.each list, (data) =>
      if data.class_name == @model.get('class_name')
        option = new Option(data.label, data.name, data.name == @model.get('inverse_of') || list.length == 1)
        @$('li.input.inverse-of select').append(option)

    # by default, select the first option
    if !@model.get('inverse_of')? && list.length > 0
      @model.set
        inverse_of: list[0].name

  render_select_options_view: ->
    @select_options_view = new Locomotive.Views.ContentTypes.SelectOptionsView
      model:      @model
      collection: @model.get('select_options')

    @$('#content_type_contents_custom_field_select_options_input').append(@select_options_view.render().el)

  make_fields_editable: ->
    @$('.label-input input[type=text], .type-input select').editableField()

  toggle: (event) ->
    event.stopPropagation() & event.preventDefault()
    form = @$('ol')

    if form.is(':hidden')
      @$('a.toggle').addClass('open')
      form.slideDown()
    else
      @$('a.toggle').removeClass('open')
      form.slideUp()

  show_error: (message) ->
    html = $("<span class=\"inline-errors\">#{message}</span>")
    @$('.required-input').after(html)

  remove: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      @$('.label-input input[type=text], .type-input select').editableField('destroy')
      super()
      @options.parent_view.remove_entry(@model, @)