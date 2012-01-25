Locomotive.Views.Sites ||= {}

class Locomotive.Views.Sites.MembershipsView extends Backbone.View

  tagName: 'div'

  className: 'list'

  _entry_views = []

  render: ->
    @render_entries()

    @enable_ui_effects()

    return @

  change_entry: (membership, value) ->
    membership.set role: value

  remove_entry: (membership) ->
    membership.set _destroy: true

  render_entries: ->
    @model.get('memberships').each (membership, index) =>
      @_insert_entry(membership, index)

  enable_ui_effects: ->
    @$('.entry select').editableField()

  _insert_entry: (membership, index) ->
    view = new Locomotive.Views.Sites.MembershipEntryView model: membership, parent_view: @, index: index

    (@_entry_views ||= []).push(view)

    $(@el).append(view.render().el)





