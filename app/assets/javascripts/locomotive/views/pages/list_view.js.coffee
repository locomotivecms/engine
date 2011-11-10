Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.ListView extends Backbone.View

  el: '#pages-list'

  render: ->
    console.log('render list view');

    @make_sortable()

    return @

  make_sortable: ->
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