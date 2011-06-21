// (function(){tinymce.create('tinymce.plugins.LocoMediafilePlugin',{init:function(ed,url){ed.addCommand('locoMediafile',function(){ed.windowManager.open({file:url+'/mediafile.htm',width:645,height:650,inline:1},{plugin_url:url})});ed.addButton('mediafile',{title:'locomediafile.image_desc',cmd:'locoMediaFile'})},getInfo:function(){return{longname:'Locomotive Media File',author:'Locomotive Engine',authorurl:'http://www.locomotivecms.com',infourl:'http://www.locomotiveapp.com',version:tinymce.majorVersion+"."+tinymce.minorVersion}}});tinymce.PluginManager.add('locomedia',tinymce.plugins.LocoMediafilePlugin)})();

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
  tinymce.create('tinymce.plugins.LocoMediaPlugin', {
    init : function(ed, url) {
      // Register commands
      ed.addCommand('locoMedia', function() {
        ed.windowManager.open({
          file : url + '/dialog.htm',
          width : 645,
          height : 650,
          inline : 1
        }, {
          plugin_url : url
        });
      });

      // Register buttons
      ed.addButton('locomedia', {
        title : 'locomedia.image_desc',
        cmd : 'locoMedia'
      });
    },

    getInfo : function() {
      return {
        longname : 'Locomotive Media File',
        author : 'Didier Lafforgue',
        authorurl : 'http://www.locomotivecms.com',
        infourl : 'http://www.locomotivecms.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add('locomedia', tinymce.plugins.LocoMediaPlugin);
})();