Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Backbone.View

  tag: 'div'

  events:
    'click ul.list a':  'select_asset'

  initialize: ->
    # _.bindAll(@, 'add_assets', 'add_asset')
    # @collection.bind('reset', @add_assets)

  render: ->
    console.log('hello world from PickerView !')

  select_asset: ->