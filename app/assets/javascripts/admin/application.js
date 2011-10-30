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
  plugins: 'safari,inlinepopups,locomedia,fullscreen',
  extended_valid_elements: 'iframe[width|height|frameborder|allowfullscreen|src|title]',
  theme_advanced_buttons1 : 'fullscreen,code,|,bold,italic,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,outdent,indent,blockquote,|,link,unlink',
  theme_advanced_buttons2 : 'formatselect,fontselect,fontsizeselect,|,locomedia',
  theme_advanced_buttons3 : '',
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  height: '300',
  width: '709',
  inlinepopups_skin: 'locomotive',
  convert_urls: false,
  fullscreen_new_window : false,
  fullscreen_settings : {
    theme_advanced_path_location : "top"
  },
  /*
  *
  * These are call backs aide in the guider creation
  *
  */
  onchange_callback: function(){
    if($('#pageeditcontent:visible').length > 0){
      guiders.next();
    }
  },
  oninit: function(){
    if(typeof window.guiders !== 'undefined' &&
       window.location.pathname.match('admin/pages/.+\/edit') != null){
      guiders.createGuider({
        attachTo: '#page_editable_elements_attributes_1_content_ifr',
        title: "Edit the content of the page",
        description: "You can edit the content of your page in this text box. Go Ahead, add somethign like 'locomotiveCMS rocks!'. We'll wait for you.",
        buttons: [],
        id: "pageeditcontent",
        next: "savepageedit",
        position: 9,
        width: 300
      });
    }
  }
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
        try{guiders.next();}catch(ex){}
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
      content.slideDown('fast', function() { parent.trigger('refresh'); });
    } else
      content.slideUp('fast', function() { parent.addClass('folded'); });
  });

  // nifty checkboxes
  $('.formtastic li.toggle input[type=checkbox]').checkToggle();

  // sites picker
  (function() {
    var link    = $('#sites-picker-link');
    var picker  = $('#sites-picker');

    if (picker.size() == 0) return;

    var left    = link.position().left + link.parent().position().left - (picker.width() - link.width());
    picker.css('left', left);
  })();
  $('#sites-picker-link').click(function(e) { $('#sites-picker').toggle(); e.stopPropagation(); e.preventDefault(); });

  // separator between form fields
  $('.formtastic fieldset.inputs').bind('refresh', function(e) { $(this).find('ol li:not(.item)').removeClass('last').filter(':visible').last().addClass('last'); })
    .trigger('refresh');

  $('.formtastic fieldset.inputs ol li:not(.item)').last().addClass('last');
});
