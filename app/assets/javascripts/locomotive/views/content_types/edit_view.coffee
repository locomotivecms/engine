Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.EditView extends Locomotive.Views.ContentTypes.FormView

  save: (event) ->
    @save_in_ajax event, on_success: (response, xhr) =>

      _.each response.entries_custom_fields, (data) =>

        custom_field = @model.get('entries_custom_fields').detect (entry) => entry.get('name') == data.name

        if custom_field.isNew() # assign an id for each new custom field
          custom_field.set id: data._id, _id: data._id

