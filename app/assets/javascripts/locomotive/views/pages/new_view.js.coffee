Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.NewView extends Backbone.View

  el: '#content'

  render: ->
    @enable_templatized_checkbox()

    @enable_redirect_checkbox()

    @enable_other_checkboxes()

    return @

  enable_templatized_checkbox: ->
    features = ['slug', 'redirect', 'listed']
    @$('li#page_templatized_input input[type=checkbox]').checkToggle
      on_callback: =>
        _.each features, (exp) -> @$('li#page_' + exp + '_input').hide()
        @$('li#page_content_type_id_input').show()
      off_callback: =>
        _.each features, (exp) -> @$('li#page_' + exp + '_input').show()
        @$('li#page_content_type_id_input').hide()

  enable_redirect_checkbox: ->
    features = ['templatized', 'cache_strategy']
    @$('li#page_redirect_input input[type=checkbox]').checkToggle
      on_callback: =>
        _.each features, (exp) -> @$('li#page_' + exp + '_input').hide()
      off_callback: =>
        _.each features, (exp) -> @$('li#page_' + exp + '_input').show()

  enable_other_checkboxes: ->
    _.each ['published', 'listed'], (exp) =>
      @$('li#page_' + exp + '_input input[type=checkbox]').checkToggle()

  _hide_last_seperator: ->
    @$('fieldset').each (fieldset) =>
      fieldset.find('li.last').removeClass('last')
      fieldset.find('li.input:visible').addClass('last')