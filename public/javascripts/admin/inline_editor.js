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

jQuery(document).ready(function($) {

  // add 'edit' at the end of each url of the page
  $('a').each(function() {
    var url = $(this).attr('href');

    if (/^(www|http)/.exec(url) == null) {
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

});
