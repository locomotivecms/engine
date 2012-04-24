Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.IndexView extends Backbone.View

  el: '#content'

  _lists_views: []

  initialize: ->
    _.bindAll(@, 'insert_asset')

  render: ->
    @build_uploader()

    @render_snippets()

    @render_images()

    @render_js_and_css()

    @render_fonts()

    @render_media()

    return @

  build_uploader: ->
    form  = @$('#theme-assets-quick-upload')
    input = form.find('input[type=file]')
    link  = form.find('a.new')

    form.formSubmitNotification()

    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      input.click()

    input.bind 'change', (event) =>
      form.trigger('ajax:beforeSend')
      _.each event.target.files, (file) =>
        asset = new Locomotive.Models.ThemeAsset(source: file)
        asset.save {},
          success:  (model, response, xhr) =>
            form.trigger('ajax:complete')
            @insert_asset(model)
          error:    (() => form.trigger('ajax:complete'))
          headers:  { 'X-Flash': true }

  insert_asset: (model) ->
    list_view = @pick_list_view(model.get('content_type'))
    list_view.collection.add(model)

  render_snippets: ->
    @render_list 'snippets', @options.snippets, Locomotive.Views.Snippets.ListView

  render_images: ->
    @render_list 'images', @options.images

  render_js_and_css: ->
    @render_list 'js-and-css', @options.js_and_css_assets, Locomotive.Views.ThemeAssets.ListView, ich.js_and_css_list

  render_fonts: ->
    @render_list 'fonts', @options.fonts, Locomotive.Views.ThemeAssets.ListView, ich.fonts_list

  render_media: ->
    @render_list 'media', @options.media, Locomotive.Views.ThemeAssets.ListView, ich.media_list

  render_list: (type, collection, view_klass, template) ->
    return if @$("##{type}-anchor").size() == 0

    view_klass ||= Locomotive.Views.ThemeAssets.ListView
    view = new view_klass(collection: collection, type: type)
    if template?
      view.template = -> template

    @$("##{type}-anchor").replaceWith(view.render().el)

    (@_lists_views ||= []).push(view)

  pick_list_view: (content_type) ->
    type = switch content_type
      when 'image'                    then 'images'
      when 'javascript', 'stylesheet' then 'js-and-css'
      when 'media'                    then 'media'
      when 'font'                     then 'fonts'

    _.find @_lists_views, (view) => view.options.type == type

  remove: ->
    _.each @_lists_views, (view) => view.remove()
    super
