class Locomotive.Models.ContentAsset extends Backbone.Model

  paramRoot: 'content_asset'

  urlRoot: "#{Locomotive.mount_on}/content_assets"

  initialize: ->
    @prepare()

  prepare: ->
    @set
      image:  @get('content_type') == 'image'

    return @

class Locomotive.Models.ContentAssetsCollection extends Backbone.Collection

  model: Locomotive.Models.ContentAsset

  url: "#{Locomotive.mount_on}/content_assets"