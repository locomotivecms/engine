class Locomotive.Models.Snippet extends Backbone.Model

  paramRoot: 'snippet'

  urlRoot: "#{Locomotive.mounted_on}/snippets"

class Locomotive.Models.SnippetsCollection extends Backbone.Collection

  model: Locomotive.Models.Snippet

  url: "#{Locomotive.mounted_on}/snippets"