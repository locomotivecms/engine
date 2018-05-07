Locomotive.Views.PageContent ||= {}

class Locomotive.Views.PageContent.EditView extends Locomotive.Views.Shared.FormView
   el: '.content-main > .actionbar .content'

   render: ->
    super