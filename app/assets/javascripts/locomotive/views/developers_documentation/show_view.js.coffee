Locomotive.Views.DevelopersDocumentation ||= {}

class Locomotive.Views.DevelopersDocumentation.ShowView extends Backbone.View

  el: '.main'

  render: ->
    super()
    @$('pre code').each -> hljs.highlightBlock(this)
