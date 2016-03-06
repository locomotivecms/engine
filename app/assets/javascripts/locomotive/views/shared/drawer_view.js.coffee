Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: '.content-main > .drawer'

  delays:
    fade:   50 # see the _transitions.css.scss file
    remove: 200

  events:
    'click .close-button': 'close'

  initialize: ->
    @stack = []
    super

  open: (url, view_klass, options = {}) ->
    console.log "[DrawerView] open, stack(#{@stack.length}) opened = #{$(@el).hasClass('drawer-open')}, #{url}"
    entry = { url: url, view_klass: view_klass, options: options }
    @push(entry)

  close: ->
    console.log "[DrawerView] close, stack(#{@stack.length})"
    @pop()

  push: (entry) ->
    @hide(@last_entry())
    @stack.push(entry)
    @show(entry)

  pop: ->
    entry = @stack.pop()
    @hide entry, => @show(@last_entry())

  replace: (entry) ->
    last_entry = @stack.pop()
    _container = @container(true)

    @stack.push(entry)

    if entry.url?
      _container.load entry.url, =>
        last_entry.view.remove() if last_entry
        @_show(entry, _container)
    else
      @_show(entry, _container)

  show: (entry) ->
    return if entry == null

    # if first time the drawer is opened, we do not need to wait
    # for the fading out of the previous screen
    timeout = if @stack.length == 1 then 0 else @delays.fade

    setTimeout =>
      _container  = @container()
      if entry.url?
        _container.load entry.url, =>
          @_show(entry, _container)
      else
        @_show(entry, _container)
    , timeout

  hide: (entry, callback) ->
    if @stack.length == 0
      # $('body').removeClass('drawer-opened')
      $(@el).removeClass('drawer-open')
    else
      entry.view.$el.addClass('fadeout') if entry?

    setTimeout =>
      if entry?
        entry.view.hide_from_drawer(@stack.length) if entry.view.hide_from_drawer?
        entry.view.remove()

      callback() if callback?
    , @delays.remove

  last_entry: ->
    if @stack.length == 0
      null
    else
      @stack[@stack.length - 1]

  container: (preserve) ->
    if preserve? && preserve
      @$('> .content-inner').find('> div')
    else
      @$('> .content-inner').html('<div></div>').find('> div')

  _show: (entry, container) ->
    _klass      = entry.view_klass
    attributes  = _.extend { el: container, drawer: @ }, entry.options

    entry.view = new _klass(attributes)
    entry.view.render()

    # $('body').addClass('drawer-opened')
    $(@el).addClass('drawer-open')
