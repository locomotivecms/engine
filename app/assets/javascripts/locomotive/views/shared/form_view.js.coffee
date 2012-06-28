Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.FormView extends Backbone.View

  el: '#content'

  render: ->
    # make title editable (if possible)
    @make_title_editable()

    @_hide_last_separator()

    # make inputs foldable (if specified)
    @make_inputs_foldable()

    # allow users to save with CTRL+S or CMD+s
    @enable_save_with_keys_combination()

    # enable form notifications
    @enable_form_notifications()

    return @

  save: (event) ->
    # by default, follow the default behaviour

  save_in_ajax: (event, options) ->
    event.stopPropagation() & event.preventDefault()

    form = $(event.target).trigger('ajax:beforeSend')

    @clear_errors()

    options ||= { headers: {}, on_success: null, on_error: null }

    previous_attributes = _.clone @model.attributes

    @model.save {},
      headers:  options.headers
      silent:   true # since we pass an empty hash above, no need to trigger the callbacks
      success: (model, response, xhr) =>
        form.trigger('ajax:complete')

        model.attributes = previous_attributes

        options.on_success(response, xhr) if options.on_success

      error: (model, xhr) =>
        form.trigger('ajax:complete')

        errors = JSON.parse(xhr.responseText)

        @show_errors errors

        options.on_error() if options.on_error

  make_title_editable: ->
    title = @$('h2 a.editable')

    if title.size() > 0
      target = @$("##{title.attr('rel')}")
      target.parent().hide()

      title.click (event) =>
        event.stopPropagation() & event.preventDefault()
        newValue = prompt(title.attr('title'), title.html());
        if newValue && newValue != ''
          title.html(newValue)
          target.val(newValue).trigger('change')

  make_inputs_foldable: ->
    self = @
    @$('.formtastic fieldset.foldable.folded ol').hide()
    @$('.formtastic fieldset.foldable legend').click ->
      parent  = $(@).parent()
      content = $(@).next()

      if parent.hasClass 'folded'
        parent.removeClass 'folded'
        content.slideDown 100, -> self.after_inputs_fold(parent)
      else
        content.slideUp 100, -> parent.addClass('folded')

  enable_save_with_keys_combination: ->
    $.cmd 'S', (() =>
      # make sure that the current text field gets saved too
      input = @$('form input[type=text]:focus, form input[type=password]:focus')
      input.trigger('change') if input.size() > 0

      @$('form input[type=submit]').trigger('click')
    ), [], ignoreCase: true


  enable_form_notifications: ->
    @$('form').formSubmitNotification()

  after_inputs_fold: ->
    # overide this method if necessary

  clear_errors: ->
    @$('.inline-errors').remove()

  show_errors: (errors) ->
    for attribute, message of errors
      if _.isString(message[0])
        html = $("<div class=\"inline-errors\"><p>#{message[0]}</p></div>")
        @show_error attribute, message[0], html
      else
        @show_error attribute, message

  show_error: (attribute, message, html) ->
    input = @$("##{@model.paramRoot}_#{attribute}")
    input = @$("##{@model.paramRoot}_#{attribute}_id") if input.size() == 0

    return unless input.size() > 0

    anchor = input.parent().find('.error-anchor')
    anchor = input if anchor.size() == 0
    anchor.after(html)

  _enable_checkbox: (name, options) ->
    options     ||= {}
    model_name  = options.model_name || @model.paramRoot

    @$("li##{model_name}_#{name}_input input[type=checkbox]").checkToggle
      on_callback: =>
        _.each options.features, (exp) -> @$("li##{model_name}_#{exp}_input").hide()
        options.on_callback() if options.on_callback?
        @_hide_last_separator()
      off_callback: =>
        _.each options.features, (exp) -> @$("li##{model_name}_#{exp}_input").show()
        options.off_callback() if options.off_callback?
        @_hide_last_separator()

  _hide_last_separator: ->
    _.each @$('fieldset'), (fieldset) =>
      $(fieldset).find('li.last').removeClass('last')
      $(_.last($(fieldset).find('li.input:visible'))).addClass('last')