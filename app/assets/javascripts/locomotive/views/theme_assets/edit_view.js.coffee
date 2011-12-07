Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.EditView extends Locomotive.Views.ThemeAssets.FormView

  save: (event) ->
    @save_in_ajax event, on_success: (response, xhr) =>
      help = @$('.inner > p.help')
      help.find('b').html(response.dimensions)
      help.find('a').html(response.url).attr('href', response.url)