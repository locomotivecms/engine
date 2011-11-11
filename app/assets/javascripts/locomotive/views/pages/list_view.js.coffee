Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.ListView extends Backbone.View

  el: '#pages-list'

  render: ->
    console.log('render list view');

    @make_sortable()

    return @

  make_sortable: ->
    self = @

    @$('ul.folder').sortable
      handle: 'em'
      axis:   'y'
      update: (event, ui) -> self.call_sort $(@)

  call_sort: (folder) ->
    $.rails.ajax
      url:        folder.attr('data-url')
      type:       'post'
      dataType:   'json'
      data:
        children: (_.map folder.sortable('toArray'), (el) -> el.replace('item-', ''))
        _method:  'put'
      success:    @.on_successful_sort
      error:      @.on_failed_sort

  # on_sort: (data) ->
  on_successful_sort: (data, status, xhr) ->
    window.foo = xhr
    $.growl('success', xhr.getResponseHeader('Flash'));

  on_failed_sort: (data, status, xhr) ->
    $.growl('error', xhr.getResponseHeader('Flash'));

        # $.post($(@).attr('data-url'), params, function(data) {
        #   var error = typeof(data.error) != 'undefined';
        #   $.growl((error ? 'error' : 'success'), (error ? data.error : data.notice));
        # }, 'json');

    # TODO
    # $('#pages-list ul.folder').sortable({
    #   'handle': 'em',
    #   'axis': 'y',
    #   'update': function(event, ui) {
    #     var params = $(this).sortable('serialize', { 'key': 'children[]' });
    #     params += '&_method=put';
    #     params += '&' + $('meta[name=csrf-param]').attr('content') + '=' + $('meta[name=csrf-token]').attr('content');
    #
    #     $.post($(this).attr('data-url'), params, function(data) {
    #       var error = typeof(data.error) != 'undefined';
    #       $.growl((error ? 'error' : 'success'), (error ? data.error : data.notice));
    #     }, 'json');
    #   }
    # });