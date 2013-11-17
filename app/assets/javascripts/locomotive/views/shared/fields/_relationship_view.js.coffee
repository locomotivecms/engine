Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.RelationshipView extends Backbone.View

  enable_select2: (element, options) ->
    options ||= {}
    options.init_selection_fn ||= (element, callback) -> null

    element.select2
      width:                '50%'
      minimumInputLength:   1
      quietMillis:          100
      allowClear:           true
      placeholder:          ' '
      initSelection: options.init_selection_fn
      ajax:
        url: options.url
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