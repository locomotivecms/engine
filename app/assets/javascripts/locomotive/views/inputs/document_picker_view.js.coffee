Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.DocumentPickerView extends Backbone.View

  initialize: ->
    super
    @$input   = @$('input[type=hidden]')
    @$link    = @$('a.edit')

  render: ->
    @$input.select2
      minimumInputLength:   1
      quietMillis:          100
      allowClear:           true
      formatNoMatches:      @$input.data('no-matches')
      formatSearching:      @$input.data('searching')
      formatInputTooShort:  @$input.data('too-short')
      initSelection:        (element, callback) =>
        callback(text: @$input.data('label'))
      ajax:
        url: @$input.data('list-url')
        data: (term, page) ->
          q:    term
          page: page
        results: (data, page) =>
          results:  @build_results(data)
          more:     data.length == @$input.data('per-page')

    # hide the edit button if the user changes the selected document
    @$input.on 'select2-selecting', (el) =>
      @$link.addClass('hide')

  build_results: (raw_data, label_method, group_by) ->
    label_method  = @$input.data('label-method')
    group_by      = @$input.data('group-by')

    _.tap [], (list) =>
      _.each raw_data, (data) =>
        if !@collection? || !@collection.get(data._id)?
          data.text = data[label_method]

          if group_by?
            group_name = _.result(data, group_by)

            # does the group exist?
            group = _.find list, (_group) -> _group.text == group_name

            unless group?
              # build a new group
              group = { text: group_name, children: [] }
              list.push(group)

            group.children.push(data)
          else
            list.push(data)

  remove: ->
    @$input.select2('destroy')
    super
