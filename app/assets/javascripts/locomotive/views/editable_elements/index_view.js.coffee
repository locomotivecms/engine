Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.IndexView extends Backbone.View

  el: '.content'

  events:
    'click .expand-button': 'expand_drawer'

  expand_drawer: (event) ->
    $('body').addClass('drawer-opened')
