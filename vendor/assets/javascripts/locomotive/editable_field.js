/**
 * Version 0.0.1
 * tiny effect to display an input field when clicking on a label
 * Didier Lafforgue
 */
$.fn.editableField = function(settings) {

  var destroy = false;

  if ('destroy' == settings) {
    destroy = true
  } else {
    settings = $.extend({}, settings);
  }

  function getText(element) {
    if (element.is('select')) {
      return element[0].options[element[0].options.selectedIndex].text;
    } else {
      return element.val();
    }
  }

  return this.each(function() {
    if (destroy) {
      $(this).unbind('mouseenter').unbind('mouseleave');
      $(this).prev('.editable').unbind('click').remove();
    } else {
      var input = $(this).hide();
      var label = $('<em></em>').addClass('editable').html(getText(input));
      var timer = null;

      input.before(label);

      label.bind('click', function() {
        label.hide();
        input.show().focus();
      });

      input.hover(function() {
        clearTimeout(timer);
      }, function() {
        timer = setTimeout(function() { input.hide(); label.show() }, 1000);
      }).change(function() {
        input.hide();
        label.show().html(getText(input))
      });
    }
  });
}