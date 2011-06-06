var I18nLocale = null;
var CodeMirrorEditors = [];

/* ___ growl ___ */

$.growl.settings.noticeTemplate = '' +
  '<div class="notice %title%">' +
  '  <p>%message%</p>' +
  '</div>';

$.growl.settings.dockCss = {
  position: 'fixed',
  bottom: '20px',
  left: '0px',
  width: '100%',
  zIndex: 50000
};

/* ___ codemirror ___ */

var addCodeMirrorEditor = function(type, el, parser) {
  parser = (parser || 'Liquid') + 'Parser';

  var editor = CodeMirror.fromTextArea(el.attr('id'), {
    height: el.hasClass('small') ? '60px' : '400px',
    stylesheet: [
      "/stylesheets/admin/plugins/codemirror/csscolors.css",
      "/stylesheets/admin/plugins/codemirror/xmlcolors.css",
      "/stylesheets/admin/plugins/codemirror/javascriptcolors.css",
      "/stylesheets/admin/plugins/codemirror/liquidcolors.css"],
    basefiles: '/javascripts/admin/plugins/codemirror/codemirror_base.min.js',
    continuousScanning: 500,
    reindentOnLoad: true,
    initCallback: function(editor) {
      jQuery(editor.frame.contentDocument).keydown(function(event) {
        jQuery(document).trigger(event);
      });
      editor.setParser(parser);
    }
  });

  CodeMirrorEditors.push({ 'el': el, 'editor': editor });
}

/* ___ tinyMCE ___ */

var TinyMceDefaultSettings = {
  script_url : '/javascripts/admin/plugins/tiny_mce/tiny_mce.js',
  theme : 'advanced',
  skin : 'locomotive',
  plugins: 'safari,inlinepopups,locoimage',
  theme_advanced_buttons1 : 'code,|,bold,italic,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,outdent,indent,blockquote,|,link,unlink',
  theme_advanced_buttons2 : 'formatselect,fontselect,fontsizeselect,|,image',
  theme_advanced_buttons3 : '',
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  height: '300',
  width: '710',
  inlinepopups_skin: 'locomotive',
  convert_urls: false
};

/* ___ global ___ */

$(document).ready(function() {
  I18nLocale = $('meta[name=locale]').attr('content');

  TinyMceDefaultSettings['language'] = I18nLocale;

  // sub menu links
  $('#submenu ul li.hoverable').hover(function() {
    $(this).find('a').addClass('hover');
    $(this).find('.popup').show();
  }, function() {
    $(this).find('a').removeClass('hover');
    $(this).find('.popup').hide();
  });

  if ((css = $('#submenu > ul').attr('class')) != '')
    $('#submenu > ul > li.' + css).addClass('on');

  // form
  $('.formtastic li input, .formtastic li textarea, .formtastic li code, .formtastic li select').focus(function() {
    $('.formtastic li.error:not(.code) p.inline-errors').fadeOut(200);
    if ($(this).parent().hasClass('error')) {
      $(this).nextAll('p.inline-errors').show();
    }
  });
  $('.formtastic li.error input').eq(0).focus();

  // nifty code editor
  $('code.html textarea').each(function() { addCodeMirrorEditor('liquid', $(this)); });

  // save form in AJAX
  $('form.save-with-shortcut').saveWithShortcut();

  // editable title (page, ...etc)
  $('#content h2 a.editable').each(function() {
    var target = $('#' + $(this).attr('rel')),
    hint = $(this).attr('title');

    target.parent().hide();

    $(this).click(function(event) {
      var newValue = prompt(hint, $(this).html());
      if (newValue && newValue != '') {
        $(this).html(newValue);
        target.val(newValue);
      }
      event.preventDefault();
    });
  });

  // foldable
  $('.formtastic fieldset.foldable legend span').append('<em>&nbsp;</em>');
  $('.formtastic fieldset.foldable.folded ol').hide();
  $('.formtastic fieldset.foldable legend').click(function() {
    var parent = $(this).parent(), content = $(this).next();
    if (parent.hasClass('folded')) {
      parent.removeClass('folded');
      content.slideDown('fast', function() {  });
    } else
      content.slideUp('fast', function() { parent.addClass('folded'); });
  });

  // nifty checkboxes
  $('.formtastic li.toggle input[type=checkbox]').checkToggle();

  // site selector
  $('#site-selector').selectmenu({ style: 'dropdown', width: 395, offsetTop: 8, change: function(event, ui) {
    $('#site-selector').parent().submit();
  } });

});
