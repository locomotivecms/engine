(function($) {
  $.fn.slug = function(o) {
    var d = {
      slug: 'slug', // Class used for slug destination input and span. The span must exists on the page
      hide: false,  // Boolean - By default the slug input field is hidden, set to false to show the input field and hide the span.
      customizable: true, // Boolean - customizable
      separate: '-', // Character - defult value set to '-'
      write: 'input', // String - the tag name for wrinting personalized slug default is set to input
      read: 'span' // String - the tag name for reading the slug default is set to span
    };
    var o = $.extend(d, o);
    return this.each(function() {
      $t = $(this);
      $w = $(o.write + "." + o.slug);
      $r = $(o.read + "." + o.slug)
      $().ready(function() {
        if (o.hide) {
          inputSlug(true);
        }
      });
      if (o.customizable) {
        $w.live('blur', function() {
          inputSlug(true)
        });
        $r.live('click', function() {
          inputSlug(false);
        });
      }

      function inputSlug(show) {
        $r.text($w.val());
        if (show) {
          $r.show();
          $w.hide();
        }
        else {
          $r.hide();
          $w.show().focus();
        }
      }

      makeSlug = function() {
        s = s.replace(/\s/g, o.separate);
        s = s.replace(eval("/[^a-z0-9" + o.separate + "]/g"), '');
        s = s.replace(eval("/" + o.separate + "{2,}/g"), o.separate);
        s = s.replace(eval("/(^" + o.separate + ")|(" + o.separate + "$)/g"), '');
        $w.val(s);
        $r.text(s);
      }

      $t.keyup(makeSlug);
      return $t;
    });
  };
})(jQuery);