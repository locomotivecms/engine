class Locomotive.Models.ContentEntry extends Backbone.Model

  paramRoot: 'content_entry'

  urlRoot: "#{Locomotive.mounted_on}/content_types/:slug/entries"

  initialize: ->
    @urlRoot = @urlRoot.replace(':slug', @get('content_type_slug'))

    _.each @get('_has_many_fields'), (field) =>
      name = field[0]
      collection = new Locomotive.Models.ContentEntriesCollection(@get(name))
      @set_attribute name, collection

  set_attribute: (attribute, value) ->
    data = {}
    data[attribute] = value
    @set data

  update_attributes: (attributes) ->
    _.each attributes._file_fields, (field) => # special treatment for files
      attribute = "#{field}_url"
      @set_attribute attribute, attributes[attribute]
      @set_attribute "remove_#{field}", false

  toJSON: ->
    _.tap super, (hash) =>
      hash['_slug'] = '' if hash['_slug'] == null # avoid empty hash
      _.each _.keys(hash), (key) =>
        unless _.include(@get('safe_attributes'), key)
          delete hash[key]

      # TODO: insert has_many

class Locomotive.Models.ContentEntriesCollection extends Backbone.Collection

  model: Locomotive.Models.ContentEntry

  url: "#{Locomotive.mounted_on}/content_types/:slug/entries"