#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  _select_field_view: null

  _file_field_views: []

  _belongs_to_field_views: []

  _has_many_field_views: []

  _many_to_many_field_views: []

  events:
    'submit': 'save'

  initialize: ->
    @content_type ||= new Locomotive.Models.ContentType(@options.content_type)

    @model ||= new Locomotive.Models.ContentEntry(@options.content_entry)

    @namespace = @options.namespace

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_checkboxes()

    @enable_tags()

    @enable_datepickers()

    @enable_datetimepickers()

    @enable_richtexteditor()

    @enable_select_fields()

    @enable_belongs_to_fields()

    @enable_file_fields()

    @enable_has_many_fields()

    @enable_many_to_many_fields()

    @slugify_label_field()

    return @

  enable_checkboxes: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle()

  enable_tags: ->
    @$('li.input.tags input[type=text]').tagit(allowSpaces: true)

  enable_datepickers: ->
    @$('li.input.date input[type=text]').datepicker()

  enable_datetimepickers: ->
    @$('li.input.date-time input[type=text]').datetimepicker
      controlType: 'select'
      showTime: false

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

  enable_select_fields: ->
    @_select_field_view = new Locomotive.Views.Shared.Fields.SelectView model: @content_type

    _.each @model.get('select_custom_fields'), (name) =>
      $input_wrapper = @$("##{@model.paramRoot}_#{name}_id_input")

      $input_wrapper.append(ich.edit_select_options_button())

      $input_wrapper.find('a.edit-options-button').bind 'click', (event) =>
        event.stopPropagation() & event.preventDefault()

        @_select_field_view.render_for name, (options) =>
          # refresh the options of the select box
          $select = $input_wrapper.find('select')
          $select.find('option[value!=""]').remove()

          _.each options, (option) =>
            unless option.destroyed()
              $select.append(new Option(option.get('name'), option.get('id'), false, option.get('id') == @model.get("#{name}_id")))

  enable_belongs_to_fields: ->
    prefix = if @namespace? then "#{@namespace}_" else ''

    _.each @model.get('belongs_to_custom_fields'), (name) =>
      $el = @$("##{prefix}#{@model.paramRoot}_#{name}_id")

      if $el.length > 0
        view = new Locomotive.Views.Shared.Fields.BelongsToView model: @model, name: name, el: $el

        @_belongs_to_field_views.push(view)

        view.render()

  enable_file_fields: ->
    prefix = if @namespace? then "#{@namespace}_" else ''

    _.each @model.get('file_custom_fields'), (name) =>
      view = new Locomotive.Views.Shared.Fields.FileView model: @model, name: name, namespace: @namespace

      @_file_field_views.push(view)

      @$("##{prefix}#{@model.paramRoot}_#{name}_input label").after(view.render().el)

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
    @$('li.input.highlighted > input[type=text]').slugify
      target: @$('#content_entry__slug')
      url:    window.permalink_service_url

  refresh_file_fields: ->
    _.each @_file_field_views, (view) => view.refresh()

  refresh: ->
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')
    @refresh_file_fields()

  reset: ->
    @$('li.input.string input[type=text], li.input.text textarea, li.input.date input[type=text]').val('').trigger('change')
    _.each @$('li.input.rte textarea.html'), (textarea) => $(textarea).tinymce().setContent(''); $(textarea).trigger('change')
    _.each @_file_field_views, (view) => view.reset()
    @$('li.input.toggle input[type=checkbox]').checkToggle('sync')

  remove: ->
    @$('li.input.date input[type=text]').datepicker('destroy')
    @$('li.input.date_time input[type=text]').datetimepicker('destroy')
    @_select_field_view.remove()
    _.each @_file_field_views, (view) => view.remove()
    _.each @_has_many_field_views, (view) => view.remove()
    _.each @_many_to_many_field_views, (view) => view.remove()
    super

  tinyMCE_settings: ->
    window.Locomotive.tinyMCE.defaultSettings

