Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.EditView extends Locomotive.Views.Shared.FormView

  render: ->
    @enable_belongs_to()
    super

  enable_belongs_to: ->
    @$('.select2 input[type=text]').each (input) ->
      options = $(input).data()
      options.init_selection_fn = (el, callback) ->
        callback(id: el.val(), text: options.value)

  # save: (event) ->
  #   @save_in_ajax event,
  #     on_success: (response, xhr) =>
  #       @model.update_attributes(response)
  #       @refresh_file_fields()
