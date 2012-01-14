class Locomotive.Models.ThemeAsset extends Backbone.Model

  paramRoot: 'theme_asset'

  urlRoot: "#{Locomotive.mounted_on}/theme_assets"

class Locomotive.Models.ThemeAssetsCollection extends Backbone.Collection

  model: Locomotive.Models.ThemeAsset

  url: "#{Locomotive.mounted_on}/theme_assets"
