class Locomotive.Models.ContentAsset extends Backbone.Model

  paramRoot: 'content_asset'

  urlRoot: "#{Locomotive.mounted_on}/content_assets"

  initialize: ->
    @prepare()

  prepare: ->
    @set(filename: @get('source').name.truncate(15)) if @get('uploading')

    @set
      image:          @get('content_type') == 'image'
      with_thumbnail: @get('content_type') == 'image' || @get('content_type') == 'pdf'

    return @

  toJSONForSave: ->
    { source: @get('source') }

class Locomotive.Models.ContentAssetsCollection extends Backbone.Collection

  model: Locomotive.Models.ContentAsset

  url: "#{Locomotive.mounted_on}/content_assets"