Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: 'section.drawer'

  delay: 200

  events:
    'click .close-button': 'close'

  initialize: ->
    @stack = []
    super

  open: (url, view_klass, parent_view) ->
    console.log "[DrawerView] open, stack(#{@stack.length}) opened = #{$('body').hasClass('drawer-opened')}, #{url}"
    entry = { url: url, view_klass: view_klass, parent_view: parent_view }
    @push(entry)

  close: ->
    console.log "[DrawerView] close, stack(#{@stack.length})"
    @pop()

  push: (entry) ->
    @hide(@last_entry())
    @stack.push(entry)
    @show(entry)

  pop: ->
    entry = @stack.pop(entry)
    @hide entry, => @show(@last_entry())

  show: (entry) ->
    return if entry == null

    _container  = @container()

    if entry.url?
      _container.load entry.url, =>
        @_show(entry, _container)
    else
      @_show(entry, _container)

  hide: (entry, callback) ->
    return if entry == null

    if @stack.length == 0
      $('body').removeClass('drawer-opened')

    setTimeout ->
      entry.view.remove()
      callback() if callback?
    , @delay

  last_entry: ->
    if @stack.length == 0
      null
    else
      @stack[@stack.length - 1]

  container: ->
    @$('> .inner').html('<div></div>').find('> div')

  _show: (entry, container) ->
    _klass = entry.view_klass

    $('body').addClass('drawer-opened')

    entry.view = new _klass(el: container, parent_view: entry.parent_view)
    entry.view.render()



