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
    },
    i18n: {
      available: ['en', 'fr', 'pt-BR']
    }
  };

  GENTICS.Aloha.EventRegistry.subscribe(GENTICS.Aloha, 'editableDeactivated', InlineEditorToolbar.updateForm);
}

jQuery(document).ready(function($) {

  InlineEditorToolbar.initialize();

  if (InlineEditorToolbar.editingMode) {
    GENTICS.Aloha.settings.i18n['current'] = InlineEditorToolbar.locale;

    // add 'edit' at the end of each url of the page
    $('a').each(function() {
      var url = $(this).attr('href');

      if (url != '#' && /^(www|http)/.exec(url) == null && /(\/edit)$/.exec(url) == null) {
        if (url == '/') url = '/index';
        $(this).attr('href', url + '/edit');
      }
    });

    // handle editable long text
    $('.editable-long-text').aloha();

    // handle editable short text
    $('.editable-short-text').each(function() {
      var link = $(this).parents('a').eq(0);
      if (link.size() == 1) { // disable click event and replace it by double click instead
        link.click(function(e) { e.stopPropagation(); e.preventDefault(); });
        link.dblclick(function(e) { window.location.href = link.attr('href'); });
      }
      $(this).aloha();
    });
  }
});
