class Locomotive.Models.Membership extends Backbone.Model

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        hash[key] = value if _.include(['id', '_id', 'role', '_destroy'], key)

class Locomotive.Models.MembershipsCollection extends Backbone.Collection

  model: Locomotive.Models.Membership

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
