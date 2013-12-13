Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.BelongsToView extends Locomotive.Views.Shared.Fields.RelationshipView

  render: ->
    @enable_select2()

    return @

  enable_select2: ->
    options = $(@el).data()
    options.init_selection_fn = (el, callback) -> callback(id: el.val(), text: options.value)

    super($(@el), options)

    $(@el).on 'select2-selecting', (el) =>
      @model.set "#{@options.name}_id", el.val