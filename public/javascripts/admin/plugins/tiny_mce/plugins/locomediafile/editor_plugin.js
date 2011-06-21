/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 */

(function() {
  tinymce.create('tinymce.plugins.LocoMediafilePlugin', {
    init : function(ed, url) {
      // Register commands
      ed.addCommand('locoMediafile', function() {
        ed.windowManager.open({
          file : url + '/mediafile.htm',
          width : 645,
          height : 540,
          inline : 1
        }, {
          plugin_url : url
        });
      });

      // Register buttons
      ed.addButton('mediafile', {
        title : 'locomediafile.image_desc',
        cmd : 'locoMediafile'
      });
    },

    getInfo : function() {
      return {
        longname : 'Locomotive mediafile',
        author : 'Locomotive Engine',
        authorurl : 'http://www.locomotiveapp.org',
        infourl : 'http://www.locomotiveapp.org',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add('locomediafile', tinymce.plugins.LocoMediafilePlugin);
})();