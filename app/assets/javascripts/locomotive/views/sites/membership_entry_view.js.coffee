Locomotive.Views.Sites ||= {}

class Locomotive.Views.Sites.MembershipEntryView extends Backbone.View

  className: 'entry'

  events:
    'change select' :   'change'
    'click a.remove':   'remove'

  render: ->
    data        = @model.toJSON()
    data.index  = @options.index

    $(@el).html(ich.membership_entry(data))

    $(@el).attr('data-role', @model.get('role'))

    @$('select').val(@model.get('role'))

    return @

  change: (event) ->
    value = $(event.target).val()
    @options.parent_view.change_entry(@model, value)

  remove: (event) ->
    event.stopPropagation() & event.preventDefault()
    @$('select').editableField('destroy')
    @options.parent_view.remove_entry(@model)
    super()