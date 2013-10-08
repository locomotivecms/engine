Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.BelongsToView extends Backbone.View

  render: ->
    @enable_select2()

    return @

  enable_select2: ->
    options = $(@el).data()

    $(@el).select2
      width:                '50%'
      minimumInputLength:   1
      quietMillis:          100
      allowClear:           true
      placeholder:          ' '
      ajax:
        url: options.url
        data: (term, page) ->
          q:    term
          page: page
        results: (data, page) ->
          results:  data.map (item) -> { id: item._id, text: item._label || '' }
          more:     data.length == options.perPage

      initSelection: (el, callback) -> callback(id: el.val(), text: options.value)

    $(@el).on 'select2-selecting', (el) =>
      @model.set "#{@options.name}_id", el.val


