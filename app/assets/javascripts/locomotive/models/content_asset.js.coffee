class Locomotive.Models.ContentAsset extends Backbone.Model

  initialize: ->
    @set
      image:  @get('content_type') == 'image'

class Locomotive.Models.ContentAssetsCollection extends Backbone.Collection

  model: Locomotive.Models.ContentAsset

  url: "#{Locomotive.mount_on}/content_assets"