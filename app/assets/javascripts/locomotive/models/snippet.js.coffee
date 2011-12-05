class Locomotive.Models.Snippet extends Backbone.Model

  paramRoot: 'snippet'

  urlRoot: "#{Locomotive.mount_on}/snippets"

class Locomotive.Models.SnippetsCollection extends Backbone.Collection