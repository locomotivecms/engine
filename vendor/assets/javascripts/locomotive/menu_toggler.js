/**
 * Version 1.0.1
 * Init and deploy childs on menu (admin)
 * Benjamin Athlan - Bewcultures
 * Andrew Bennett - Delorum
 * Didier Lafforgue - NoCoffee
 */
$.fn.toggleMe = function(settings) {

  settings = $.extend({}, settings);

  var toggle = function(event) {
    var toggler     = $(this);
    var children    = toggler.parent().find('> ul.folder');
    var openClass   = toggler.data('open')
    var closedClass = toggler.data('closed')

    children.each(function() {
      var child = $(this);

      if (child.is(':visible')) {
        child.slideUp('fast', function() {
          toggler.removeClass(openClass).addClass(closedClass)
          $.cookie(child.attr('id'), 'none');
        });
      } else {
        child.slideDown('fast', function() {
          toggler.removeClass(closedClass).addClass(openClass)
          $.cookie(child.attr('id'), 'block');
        });
      }
    });
  };

  return $(this).bind('click', toggle);

};