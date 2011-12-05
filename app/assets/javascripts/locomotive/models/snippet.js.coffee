class Locomotive.Models.Snippet extends Backbone.Model

  paramRoot: 'snippet'

  urlRoot: "#{Locomotive.mount_on}/snippets"

  initialize: ->

class Locomotive.Models.SnippetsCollection extends Backbone.Collection