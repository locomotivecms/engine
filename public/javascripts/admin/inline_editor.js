var foo = bar = null;

var locale = 'en';

// var foo = null;

var allTranslations = {
  'en': {
    'home': 'admin',
    'edit': 'edit',
    'save': 'save',
    'cancel': 'cancel',
    'back': 'edition done',
    'saving': 'saving'
  },
  'fr': {
    'home': 'admin',
    'edit': 'editer',
    'save': 'sauver',
    'cancel': 'annuler',
    'back': 'fin mode edition',
    'saving': 'sauvegarde en cours'
  }
}

var prepareForm = function(jEvent, aEvent) {
  // console.log('foo !!!');
  // console.log(ui.editable.getContents());
  $('#page-toolbar li.save, #page-toolbar li.cancel, #page-toolbar li.sep:eq(1)').show();

  var element = $(aEvent.editable.obj[0]);
  // var id = element.attr('data-element-id');
  var index = element.attr('data-element-index');

  // console.log('id = ' + id + ', index = ' + index);

  // if ($('#page-toolbar form editable-' + index).length > 0) return;
  //
  // $('#page-toolbar form').append("\
  //   <input id='editable-" + index +"' class='auto' type='hidden' name='page[editable_elements_attributes][" + index + "][id]' value='" + id + "' />\
  //   <input class='auto' type='hidden' name='page[editable_elements_attributes][" + index + "][_index]' value='" + index + "' />\
  //   <input class='auto' type='hidden' name='page[editable_elements_attributes][" + index + "][content]' />\
  // ");

  // $('#page-toolbar form input:last').val(aEvent.editable.getContents());

  var input = $('#page-toolbar form #editable-' + index);

  input.attr('name', input.attr('name').replace('_index', 'content'));
  input.val(aEvent.editable.getContents().replace(/^\s*/, "").replace(/\s*$/, ""));

  $('#page-toolbar').css('right', 0);
  $('#page-toolbar .drawer a').removeClass('off');

  // foo = $(this);

  // $(foo.editable.obj[0])

  // console.log($(this).attr('data-element-id'));

  // bar = a;
  // foo = ui;
}

var displaySpinner = function() {
  $('#page-toolbar li.save, #page-toolbar li.cancel, #page-toolbar li.sep:eq(1)').hide();
  $('#page-toolbar .spinner').show();
};

var resetForm = function() {
  $('#page-toolbar form input.auto').each(function() {
    $(this).attr('name', $(this).attr('name').replace('content', '_index'));
    $(this).val('');
  });

  $('#page-toolbar li.save, #page-toolbar li.cancel, #page-toolbar li.sep:eq(1), #page-toolbar li.spinner').hide();
}

if (typeof GENTICS != 'undefined') {
  GENTICS.Aloha.settings = {
    errorhandling : false,
    ribbon: false,
    "plugins": {
      // "com.gentics.aloha.plugins.GCN": {
      //   "enabled": false
      // },
      "com.gentics.aloha.plugins.Format": {
        config : [ 'b', 'i', 'u','del','sub','sup', 'p', 'title', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre', 'removeFormat'],
        editables : {
          '.editable-short-text' : [ 'b', 'i', 'u' ]
        }
      },
      "com.gentics.aloha.plugins.Link": {
        // all elements with no specific configuration may insert links
        config : [ 'a' ],
        editables : {
          '.editable-short-text' : [ ]
        }
      },
      "com.gentics.aloha.plugins.List": {
        config : [ 'ul' ],
        editables : {
          '.editable-short-text' : [ ]
        }
      }
    }
  };

  GENTICS.Aloha.EventRegistry.subscribe(GENTICS.Aloha, "editableDeactivated", prepareForm);
}

var editingMode = false;

var buildPageToolbar = function() {
  var fullpath = $('meta[name=page-fullpath]').attr('content');
  var showPageUrl = $('meta[name=page-url]').attr('content');
  var editPageUrl = $('meta[name=edit-page-url]').attr('content');
  var nbElements = parseInt($('meta[name=page-elements-count]').attr('content'));
  var translations = allTranslations[locale];

  editingMode = typeof showPageUrl != 'undefined';
  var style = editingMode ? '' : "style='display: none'"

  var formContentHTML = "<input type='hidden' name='_method' value='put' />";
  for (var i = 0; i < nbElements; i++) {
    formContentHTML += "<input class='auto' id='editable-" + i + "' type='hidden' name='page[editable_elements_attributes][" + i + "][_index]' value='' />";
  }

  $('body').prepend("<div id='page-toolbar'>\
    <ul>\
      <li class='drawer'><a href='#'><span>&nbsp;</span></a></li>\
      <li class='link home'><a href='" + editPageUrl + "'><span>" + translations['home'] + "</span></a></li>\
      <li class='sep'><span>&nbsp;</span></li>\
      <li class='link edit' style='" + (editingMode ? 'display: none' : '') + "'><a href='#'><span>" + translations['edit'] + "</span></a></li>\
      <li class='link save' style='display: none'><a href='#'><span>" + translations['save'] + "</span></a></li>\
      <li class='link cancel' style='display: none'><a href='#'><span>" + translations['cancel'] + "</span></a></li>\
      <li class='link spinner' style='display: none'><a href='#'><span><img src='/images/admin/form/spinner.gif' /><em>" + translations['saving'] + "</em></span></a></li>\
      <li class='sep' style='display: none'><span>&nbsp;</span></li>\
      <li class='link back' style='" + (editingMode ? '' : 'display: none') + "'><a href='#'><span>" + translations['back'] + "</span></a></li>\
    </ul>\
    <form action='" + showPageUrl + "' accept-charset='UTF-8' method='post'>\
      " + formContentHTML + "\
    </form>\
  </div>");

  // build the form
  $('#page-toolbar form').live('submit', function (e) {
    $(this).callRemote();
    e.stopPropagation();
    e.preventDefault();
  }).bind('ajax:complete', function() {
    // console.log('ajax:complete');
    resetForm();
  }).bind('ajax:loading', function() {
    // console.log('ajax:failure');
    displaySpinner();
  }).bind('ajax:failure', function() {
    // console.log('ajax:failure');
    resetForm();
  });

  // events: save
  $('#page-toolbar').find('.save').click(function(e) {
    $('#page-toolbar form').submit();
    e.preventDefault();
  });

  // events: edit
  $('#page-toolbar').find('.edit').click(function() {
    url = window.location.href;
    if (url.charAt(url.length - 1) == '/') url += 'index';
    url = url.replace('#', '');
    window.location.href =  url + '/edit';
  });

  // events: cancel
  $('#page-toolbar').find('.cancel').click(function(e) {
    e.preventDefault(); e.stopPropagation();
    window.location.href = window.location.href;
  });

  // events: back
  $('#page-toolbar').find('.back').click(function(e) {
    e.preventDefault(); e.stopPropagation();
    window.location.href = fullpath;
  });

  // drawer
  $('#page-toolbar .drawer a').eq(0).click(function(e) {
    var self = $(this);
    var max = $('#page-toolbar').width() - 17;

    if ($(this).hasClass('off'))
      $('#page-toolbar').animate({ 'right': 0 }, 300, function() {
        self.removeClass('off');
        $.cookie('inline_editor_off', '0');
      });
    else
      $('#page-toolbar').animate({ 'right': -max }, 300, function() {
        self.addClass('off');
        $.cookie('inline_editor_off', '1');
      });

    e.stopPropagation(); e.preventDefault();
  });
}

jQuery(document).ready(function($) {

  locale = $('meta[name=locale]').attr('content');

  buildPageToolbar();

  if ($.cookie('inline_editor_off') == '1') {
    var max = $('#page-toolbar').width() - 17;
    $('#page-toolbar').css('right', -max);
    $('#page-toolbar .drawer a').addClass('off');
  }

  if (editingMode) {
    // set locale
    GENTICS.Aloha.settings['i18n'] = { 'current': locale };

    // add 'edit' at the end of each url of the page
    $('a').each(function() {
      var url = $(this).attr('href');

      if (url != '#' && /^(www|http)/.exec(url) == null && /(\/edit)$/.exec(url) == null) {
        if (url == '/') url = '/index';
        $(this).attr('href', url + '/edit');
      }
    });

    // handle editable long text
    $('.editable-long-text').each(function(index) {

      var self = $(this);
      // var postId = self.attr("data-id");
      // var postField = self.attr("data-field");

      // add callbacks to update post data fields:
      self.aloha();
    });

    // handle editable short text
    $('.editable-short-text').each(function() {
      var self = $(this);

      var link = self.parents('a');
      if (link.size() == 1) {
        link = link.eq(0);

        // disable click event and replace it by double click instead
        link.click(function(e) { e.stopPropagation(); e.preventDefault(); });
        link.dblclick(function(e) { window.location.href = link.attr('href'); });
      }

      self.aloha();
    });
  }
});
