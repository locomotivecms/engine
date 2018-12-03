#= require ../shared/form_view

Locomotive.Views.Roles ||= {}

class Locomotive.Views.Roles.NewView extends Locomotive.Views.Shared.FormView

  el: '.main'

  initialize: ->
    tree = @$('.tree-view-div').tree(
      primaryKey: 'id',
      uiLibrary: 'bootstrap',
      dataSource: JSON.parse(@$('.tree-view-div').attr('data-source')),
      checkboxes: true)

    @$('.edit_role').on 'submit', (e) ->
      $('.role-pages-input').val(tree.getCheckedNodes())