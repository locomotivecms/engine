/**
 * Version 0.0.1
 * Fill in an input field from another one (source)
 * and apply a filter on the string (slugify)
 * Didier Lafforgue
 */
$.fn.slugify = function(settings) {

  settings = $.extend({
    sep: '-'
  }, settings);

  var target = $(settings.target);
  target.data('touched', (target.val() != ''));

  var makeSlug = function(event) {
    var source = $(this);
    var newVal = source.val().slugify(settings.sep);

    if (!target.data('touched')) {
      target.val(newVal);
      target.trigger('change');
    }
  }

  target.bind('keyup', function(event) {
    $(this).data('touched', ($(this).val() != ''));
  });

  return $(this).bind('keyup', makeSlug);
};