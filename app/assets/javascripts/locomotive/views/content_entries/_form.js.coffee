#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  _file_field_views: []

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.ContentEntry(@options.content_entry)

    console.log(@model.urlRoot)

    window.foo = @model

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_checkboxes()

    @enable_datepickers()

    @enable_richtexteditor()

    @enable_file_fields()

    @slugify_label_field()

    return @

  enable_checkboxes: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()

  enable_datepickers: ->
    @$('li.input.date input[type=text]').datepicker()

  enable_richtexteditor: ->
    _.each @$('li.input.rte textarea.html'), (textarea) =>
      settings = _.extend {}, window.Locomotive.tinyMCE.defaultSettings,
        onchange_callback: (editor) =>
          $(textarea).val(editor.getBody().innerHTML).trigger('change')

      $(textarea).tinymce(settings)

  enable_file_fields: ->
    _.each @model.get('_file_fields'), (name) =>
      view = new Locomotive.Views.Shared.Fields.FileView model: @model, name: name

      @_file_field_views.push(view)

      @$("##{@model.paramRoot}_#{name}_input").append(view.render().el)

  slugify_label_field: ->
    @$('li.input.highlighted > input[type=text]').slugify(target: @$('#content_entry__slug'))

  refresh_file_fields: ->
    console.log('refresh_file_fields')
    _.each @_file_field_views, (view) => view.refresh()

  remove: ->
    _.each @_file_field_views, (view) => view.remove()
    super

