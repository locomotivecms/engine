class Locomotive.Models.EditableElement extends Backbone.Model


class Locomotive.Models.EditableElementsCollection extends Backbone.Collection

  blocks: ->
    names = _.uniq(@map (editable, index) -> editable.get('block_name'))
    _.tap [], (list) =>
      _.each names, (name, index) ->
        list.push name: name, index: index

  by_block: (name) ->
    @filter (editable) -> editable.get('block_name') == name
