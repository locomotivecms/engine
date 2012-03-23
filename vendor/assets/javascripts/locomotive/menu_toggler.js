/**
 * Version 1.0.1
 * Init and deploy childs on menu (admin)
 * Benjamin Athlan - Bewcultures
 * Andrew Bennett - Delorum
 */
$.fn.toggleMe = function(settings) {

  settings = $.extend({}, settings);

  var toggle = function(event) {
    var toggler   = $(this);
    var children  = toggler.parent().find('> ul.folder');

    children.each(function() {
      var child = $(this);
      if (child.is(':visible')) {
        child.slideUp('fast', function() {
          toggler.attr('src', toggler.attr('src').replace('open', 'closed'));
          $.cookie(child.attr('id'), 'none');
        });
      } else {
        child.slideDown('fast', function() {
          toggler.attr('src', toggler.attr('src').replace('closed', 'open'));
          $.cookie(child.attr('id'), 'block');
        });
      }
    });
  };

  return $(this).bind('click', toggle);

};