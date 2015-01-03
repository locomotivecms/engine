Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.DocumentPickerView extends Backbone.View

  initialize: ->
    super
    @$input = @$('input[type=hidden]')

  render: ->
    @enable_select2()

  enable_select2: ->
    @$input.select2
      width:                '50%'
      minimumInputLength:   1
      quietMillis:          100
      allowClear:           true
      placeholder:          ' '
      initSelection:        (element, callback) =>
        @$input.data('label')
      ajax:
        url: @$input.data('url')
        data: (term, page) ->
          q:    term
          page: page
        results: (data, page) =>
          results:  @build_results(data, options.groupBy)
          more:     data.length == options.perPage

  build_results: (raw_data, group_by) ->
    _.tap [], (list) =>
      _.each raw_data, (data) =>
        if !@collection? || !@collection.get(data._id)?
          data.text = data._label

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
    console.log 'TODO'
    super
