#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  _file_field_views: []

  _has_many_field_views: []

  _many_to_many_field_views: []

  events:
    'submit': 'save'

  initialize: ->
    @model ||= new Locomotive.Models.ContentEntry(@options.content_entry)

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_checkboxes()

    @enable_datepickers()

    @enable_richtexteditor()

    @enable_file_fields()

    @enable_has_many_fields()

    @enable_many_to_many_fields()

    @slugify_label_field()

    return @

  enable_checkboxes: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()

  enable_datepickers: ->
    @$('li.input.date input[type=text]').datepicker()

  enable_richtexteditor: ->
    _.each @$('li.input.rte textarea.html'), (textarea) =>
      settings = _.extend {}, @tinyMCE_settings(),
        oninit: ((editor) =>
          $.cmd 'S', (() =>
            editor.save()
            $(textarea).trigger('changeSilently')
            @$('form').trigger('submit')
          ), [], ignoreCase: true, document: editor.dom.doc),
        onchange_callback: (editor) =>
          editor.save()
          $(textarea).trigger('changeSilently')

      $(textarea).tinymce(settings)

  enable_file_fields: ->
    _.each @model.get('file_custom_fields'), (name) =>
      view = new Locomotive.Views.Shared.Fields.FileView model: @model, name: name

      @_file_field_views.push(view)

      @$("##{@model.paramRoot}_#{name}_input label").after(view.render().el)

  enable_has_many_fields: ->
    unless @model.isNew()
      _.each @model.get('has_many_custom_fields'), (field) =>
        name = field[0]; inverse_of = field[1]
        new_entry = new Locomotive.Models.ContentEntry(@options["#{name}_new_entry"])
        view      = new Locomotive.Views.Shared.Fields.HasManyView model: @model, name: name, new_entry: new_entry, inverse_of: inverse_of

        if view.ui_enabled()
          @_has_many_field_views.push(view)

          @$("##{@model.paramRoot}_#{name}_input label").after(view.render().el)

  enable_many_to_many_fields: ->
    _.each @model.get('many_to_many_custom_fields'), (field) =>
      name = field[0]
      view = new Locomotive.Views.Shared.Fields.ManyToManyView model: @model, name: name, all_entries: @options["all_#{name}_entries"]

      if view.ui_enabled()
        @_many_to_many_field_views.push(view)

        @$("##{@model.paramRoot}_#{name}_input label").after(view.render().el)

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
    _.each @_many_to_many_field_views, (view) => view.remove()
    super

  tinyMCE_settings: ->
    window.Locomotive.tinyMCE.defaultSettings

