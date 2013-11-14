class Locomotive.Models.EditableElement extends Backbone.Model

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        hash[key] = value if _.include(['id', 'source', 'content', 'remove_source'], key)

      if @get('type') == 'EditableFile'
        delete hash['content']
      else
        delete hash['source']

class Locomotive.Models.EditableElementsCollection extends Backbone.Collection

  model: Locomotive.Models.EditableElement

  blocks: ->
    names = _.uniq(@map (editable, index) -> editable.get('block_name'))
    _.tap [], (list) =>
      _.each names, (name, index) ->
        list.push name: name, index: index

  by_block: (name) ->
    @filter (editable) -> editable.get('block_name') == name

  find_similar: (editable) ->
    @find (_editable) ->
      editable.get('block') == _editable.get('block') &&
      editable.get('slug')  == _editable.get('slug') &&
      editable.get('type')  == _editable.get('type')

  update_content_from: (collection) ->
    collection.each (element) =>
      _element = @find_similar(element)
      _element.set('content', element.get('content')) if _element

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
