$(document).ready(function() {

  // sortable items
  $('ul#contents-list.sortable').sortable({
    'handle': 'em',
    'items': 'li.content',
    'axis': 'y',
    'update': function(event, ui) {
      var params = $(this).sortable('serialize', { 'key': 'children[]' });
      params += '&_method=put';
      params += '&' + $('meta[name=csrf-param]').attr('content') + '=' + $('meta[name=csrf-token]').attr('content');

      $.post($(this).attr('data-url'), params, function(data) {
        var error = typeof(data.error) != 'undefined';
        $.growl((error ? 'error' : 'success'), (error ? data.error : data.notice));
      }, 'json');
    }
  });

  try {
    $('textarea.html').tinymce(TinyMceDefaultSettings);
  } catch (e) { /* tinymce not loaded */ }

  $.datepicker.setDefaults($.datepicker.regional[I18nLocale]);
  $('input[type=text].date').datepicker($.datepicker.regional[I18nLocale]);
});
