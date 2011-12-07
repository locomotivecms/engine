Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.IndexView extends Backbone.View

  el: '#content'

  _lists_views: []

  initialize: ->
    _.bindAll(@, 'add_asset')

  render: ->
    @build_uploader()

    @render_snippets()

    @render_images()

    @render_js_and_css()

    @render_fonts()

    @render_media()

    return @

  build_uploader: ->
    el    = @$('.quick-upload input[type=file]')
    link  = @$('.quick-upload a.new')
    window.Locomotive.Uploadify.build el,
      url:        link.attr('href')
      data_name:  el.attr('name')
      file_ext:   '*.jpg;*.png;*.jpeg;*.gif;*.flv;*.swf;*.ttf;*.js;*.css;*.mp3'
      height:     link.outerHeight()
      width:      link.outerWidth()
      success:    (model) => @add_asset(model)
      error:      (msg)   =>
        console.log(msg)
        $.growl('alert', msg)

  add_asset: (model) ->
    console.log(model)
    list_view = @pick_list_view(model.content_type)
    console.log(list_view)
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
