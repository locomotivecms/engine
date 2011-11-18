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
      view = new Locomotive.Views.ContentAssets.PickerView();

      // Register commands
      ed.addCommand('locoMedia', function() {
        view.render();
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

// (function(){tinymce.create('tinymce.plugins.LocoMediaPlugin',{init:function(ed,url){ed.addCommand('locoMedia',function(){ed.windowManager.open({file:url+'/dialog.htm?8',width:645,height:350,inline:1},{plugin_url:url})});ed.addButton('locomedia',{title:'locomedia.image_desc',cmd:'locoMedia'})},getInfo:function(){return{longname:'Locomotive Media File',author:'Didier Lafforgue',authorurl:'http://www.locomotivecms.com',infourl:'http://www.locomotivecms.com',version:tinymce.majorVersion+"."+tinymce.minorVersion}}});tinymce.PluginManager.add('locomedia',tinymce.plugins.LocoMediaPlugin)})();