/**
 * Version 0.0.1
 * Fill in an input field from another one (source)
 * and apply a filter on the string (slugify)
 * Didier Lafforgue
 */
$.fn.slugify = function(settings) {

  settings = $.extend({
    sep: '-',
    url: null,
    underscore: false
  }, settings);

  var target = $(settings.target);
  target.data('touched', (target.val() != ''));

  var makeSlug = function(event) {
    var source = $(this);

    if (settings.url != null) {
      // Ajax call instead meaning rely on the server to get the slugified version of the field
      params = { 'string': source.val(), 'underscore': (settings.underscore ? '1' : '0') };
      jQuery.getJSON(settings.url, params, function(data, textStatus, jqXHR) {
        var newVal = data['value']

        if (!target.data('touched')) {
          target.val(newVal);
          target.trigger('change');
        }
      });
    } else {
      var newVal = source.val().slugify(settings.sep);

      if (!target.data('touched')) {
        target.val(newVal);
        target.trigger('change');
      }
    }
  }

  target.bind('keyup', function(event) {
    $(this).data('touched', ($(this).val() != ''));
  });

  return $(this).bind('keyup', makeSlug);
};