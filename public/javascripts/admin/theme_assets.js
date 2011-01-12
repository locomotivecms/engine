/* ___ file or text ___ */

var enableFileOrTextToggling = function() {
  $('div.hidden').hide();

  $('span.alt').click(function(event) {
    event.preventDefault();

    if ($("div#file-selector").is(":hidden")) {
      $("div#text-selector").slideUp("normal", function() {
        $("div#file-selector").slideDown();
        $("input#theme_asset_performing_plain_text").val(false);
      });
    } else {
      $("div#file-selector").slideUp("normal", function() {
        $("div#text-selector").slideDown();
        $("input#theme_asset_performing_plain_text").val(true);
      });
    }
  });
}

$(document).ready(function() {
  enableFileOrTextToggling();

  $('code.stylesheet textarea').each(function() {
    addCodeMirrorEditor(null, $(this), 'CSS');
  });
  $('code.javascript textarea').each(function() {
    addCodeMirrorEditor(null, $(this), 'JS');
  });

  $('select#theme_asset_content_type').bind('change', function() {
    var editor = CodeMirrorEditors[0].editor;
    editor.setParser($(this).val() == 'stylesheet' ? 'CSSParser' : 'JSParser');
  });

  $('a#image-picker-link').imagepicker({
    insertFn: function(link) {
      return link.attr('href');
    }
  });
});
