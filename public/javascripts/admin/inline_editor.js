if (typeof GENTICS != 'undefined') {
  GENTICS.Aloha.settings = {
    errorhandling : false,
    ribbon: false,
    "i18n": {"current": "en"},
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
}

var editingMode = false;

var buildPageToolbar = function() {
  var fullpath = $('meta[name=page-fullpath]').attr('content');
  var showPageUrl = $('meta[name=page-url]').attr('content');
  var editPageUrl = $('meta[name=edit-page-url]').attr('content');

  editingMode = typeof showPageUrl != 'undefined';
  var style = editingMode ? '' : "style='display: none'"

  $('body').prepend("<div id='page-toolbar'>\
    <ul>\
      <li class='drawer'><a href='#'><span>&nbsp;</span></a></li>\
      <li class='link home'><a href='" + editPageUrl + "'><span>admin</span></a></li>\
      <li class='sep'><span>&nbsp;</span></li>\
      <li class='link edit' style='" + (editingMode ? 'display: none' : '') + "'><a href='#'><span>edit</span></a></li>\
      <li class='link save' style='display: none'><a href='#'><span>save</span></a></li>\
      <li class='link cancel' style='display: none'><a href='#'><span>cancel</span></a></li>\
      <li class='link back' style='" + (editingMode ? '' : 'display: none') + "'><a href='#'><span>back</span></a></li>\
    </ul>\
  </div>");

  // events
  $('#page-toolbar').find('.edit').click(function() {
    url = window.location.href;
    if (url.charAt(url.length - 1) == '/') url += 'index';
    window.location.href =  url + '/edit';
  });

  $('#page-toolbar').find('.cancel').click(function(e) {
    e.preventDefault(); e.stopPropagation();
    window.location.href = window.location.href;
  });

  $('#page-toolbar').find('.back').click(function(e) {
    e.preventDefault(); e.stopPropagation();
    window.location.href = fullpath;
  });

  $('#page-toolbar').find('.drawer a').eq(0).click(function() {
    var self = $(this);
    var max = $('#page-toolbar').width() - 17;

    if ($(this).hasClass('off'))
      $('#page-toolbar').animate({ 'right': 0 }, 300, function() {
        self.removeClass('off');
      });
    else
      $('#page-toolbar').animate({ 'right': -max }, 300, function() {
        self.addClass('off');
      });
  });
}

jQuery(document).ready(function($) {

  buildPageToolbar();

  if (editingMode) {
    // add 'edit' at the end of each url of the page
    $('a').each(function() {
      var url = $(this).attr('href');

      if (/^(www|http)/.exec(url) == null && /(\/edit)$/.exec(url) == null) {
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
