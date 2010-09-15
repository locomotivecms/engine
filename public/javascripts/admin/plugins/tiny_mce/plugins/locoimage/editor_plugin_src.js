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
  tinymce.create('tinymce.plugins.LocoImagePlugin', {
    init : function(ed, url) {
      // Register commands
      ed.addCommand('locoImage', function() {
        ed.windowManager.open({
          file : url + '/image.htm',
          width : 645,
          height : 650,
          inline : 1
        }, {
          plugin_url : url
        });
      });

      // Register buttons
      ed.addButton('image', {
        title : 'locoimage.image_desc',
        cmd : 'locoImage'
      });
    },

    getInfo : function() {
      return {
        longname : 'Locomotive image',
        author : 'Locomotive Engine',
        authorurl : 'http://www.locomotiveapp.org',
        infourl : 'http://www.locomotiveapp.org',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add('locoimage', tinymce.plugins.LocoImagePlugin);
})();