class Locomotive.Models.ContentEntry extends Backbone.Model

  paramRoot: 'content_entry'

  urlRoot: "#{Locomotive.mount_on}/content_type/:slug/entries"

class Locomotive.Models.ContentEntriesCollection extends Backbone.Collection

  model: Locomotive.Models.Content

  url: "#{Locomotive.mount_on}/content_type/:slug/entries"