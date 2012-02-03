#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  _file_field_views: []

  _has_many_field_views: []

  events:
    'submit': 'save'

  initialize: ->
    @model ||= new Locomotive.Models.ContentEntry(@options.content_entry)

    window.foo = @model

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_checkboxes()

    @enable_datepickers()

    @enable_richtexteditor()

    @enable_file_fields()

    @enable_has_many_fields()

    @slugify_label_field()

    return @

  enable_checkboxes: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()

  enable_datepickers: ->
    @$('li.input.date input[type=text]').datepicker()

  enable_richtexteditor: ->
    _.each @$('li.input.rte textarea.html'), (textarea) =>
      settings = _.extend {}, @tinyMCE_settings(),
        onchange_callback: (editor) =>
          $(textarea).val(editor.getBody().innerHTML).trigger('change')

      $(textarea).tinymce(settings)

  enable_file_fields: ->
    _.each @model.get('_file_fields'), (name) =>
      view = new Locomotive.Views.Shared.Fields.FileView model: @model, name: name

      @_file_field_views.push(view)

      @$("##{@model.paramRoot}_#{name}_input").append(view.render().el)

  enable_has_many_fields: ->
    _.each @model.get('_has_many_fields'), (field) =>
      name = field[0]; inverse_of = field[1]
      new_entry = new Locomotive.Models.ContentEntry(@options["#{name}_new_entry"])
      view      = new Locomotive.Views.Shared.Fields.HasManyView model: @model, name: name, new_entry: new_entry, inverse_of: inverse_of

      @_has_many_field_views.push(view)

      @$("##{@model.paramRoot}_#{name}_input").append(view.render().el)

  slugify_label_field: ->
    @$('li.input.highlighted > input[type=text]').slugify(target: @$('#content_entry__slug'))

  refresh_file_fields: ->
    _.each @_file_field_views, (view) => view.refresh()

  refresh: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')
    _.each @_file_field_views, (view) => view.refresh()

  reset: ->
    @$('li.input.string input[type=text], li.input.text textarea, li.input.date input[type=text]').val('').trigger('change')
    _.each @$('li.input.rte textarea.html'), (textarea) => $(textarea).tinymce().setContent(''); $(textarea).trigger('change')
    _.each @_file_field_views, (view) => view.reset()
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')

  remove: ->
    _.each @_file_field_views, (view) => view.remove()
    _.each @_has_many_field_views, (view) => view.remove()
    super

  tinyMCE_settings: ->
    window.Locomotive.tinyMCE.defaultSettings

