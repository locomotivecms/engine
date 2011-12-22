class Locomotive.Models.Content extends Backbone.Model

  paramRoot: 'content'

  urlRoot: "#{Locomotive.mount_on}/content_type/:slug/contents"

class Locomotive.Models.ContentsCollection extends Backbone.Collection

  model: Locomotive.Models.Content

  url: "#{Locomotive.mount_on}/content_type/:slug/contents"