window.Select2Helpers = (->

  default_build_options = (input) ->
    minimumInputLength:   1
    quietMillis:          100
    formatNoMatches:      input.data('no-matches')
    formatSearching:      input.data('searching')
    formatInputTooShort:  input.data('too-short')
    ajax:
      url:      input.data('list-url')
      dataType: 'json'
      data: (params) ->
        q:    params.term
        page: params.page
      processResults: (data, params) ->
        results: build_results data, input.data('label-method'), input.data('group-by')
        pagination:
          more: data.length == input.data('per-page')

  build_results = (raw_data, label_method, group_by) ->
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

  build: (input, options) ->
    options   ||= {}
    _options  = _.extend(default_build_options(input), options)

    input.select2 _options

)()
