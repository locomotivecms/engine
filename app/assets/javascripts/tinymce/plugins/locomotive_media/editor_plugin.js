/**
 * LocomotiveMedia plugin
 *
 * Copyright 2011, Didier Lafforgue
 * Released under MIT License.
 *
 */

(function() {
  var insertImage = function(ed, asset) {
    var args = {}, el;

    // Fixes crash in Safari
    if (tinymce.isWebKit) ed.getWin().focus();

    if (asset.get('image'))
      tinymce.extend(args, { src : asset.get('url') });
    else
      tinymce.extend(args, { href : asset.get('url') });

    el = ed.selection.getNode();

    if (el && (el.nodeName == 'IMG' || el.nodeName == 'A')) {
     ed.dom.setAttribs(el, args);
    } else {
      if (asset.get('image')) {
        ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" />', { skip_undo: 1 });
      } else {
        var html = ed.selection.getContent();
        if (html == '') html = asset.get('filename');
        ed.execCommand('mceInsertContent', false, '<a id="__mce_tmp" >' + html + '</a>', { skip_undo: 1 });
      }

      ed.dom.setAttribs('__mce_tmp', args);
      ed.dom.setAttrib('__mce_tmp', 'id', '');
      ed.undoManager.add();
    }
  }

  tinymce.create('tinymce.plugins.LocomotiveMediaPicker', {
    init : function(ed, url) {
      view = new Locomotive.Views.ContentAssets.PickerView({
        'collection': new Locomotive.Models.ContentAssetsCollection()
      });

      view.render();

      // Register commands
      ed.addCommand('locomotiveMedia', function() {
        view.options.on_select = function(asset) {
          insertImage(ed, asset);
          view.close();
        }

        view.fetch_assets();
      });

      // Register buttons
      ed.addButton('locomotive_media', {
        title : 'locomotive_media.image_desc',
        cmd : 'locomotiveMedia'
      });
    },

    getInfo : function() {
      return {
        longname : 'Locomotive Media Picker',
        author : 'Didier Lafforgue',
        authorurl : 'http://www.locomotivecms.com',
        infourl : 'http://www.locomotivecms.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add('locomotive_media', tinymce.plugins.LocomotiveMediaPicker);
})();
