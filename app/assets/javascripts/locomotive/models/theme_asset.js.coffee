class Locomotive.Models.ThemeAsset extends Backbone.Model

  paramRoot: 'theme_asset'

  urlRoot: "#{Locomotive.mount_on}/theme_assets"

class Locomotive.Models.ThemeAssetsCollection extends Backbone.Collection

  model: Locomotive.Models.ThemeAsset

  url: "#{Locomotive.mount_on}/theme_assets"
