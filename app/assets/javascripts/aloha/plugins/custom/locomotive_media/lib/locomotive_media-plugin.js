define(
  ['aloha/jquery', 'aloha/plugin', 'ui/ui', 'ui/button', 'i18n!aloha/nls/i18n', 'i18n!locomotive_media/nls/i18n', 'css!locomotive_media/css/image.css'],
  function(aQuery, Plugin, Ui, Button, i18nCore, i18n) {
      var jQuery = aQuery;
      var $ = aQuery;
      var GENTICS = window.GENTICS, Aloha = window.Aloha;

      return Plugin.create('locomotive_media', {
        init: function() {
          this._addUIInsertButton();
        },

        openDialog: function() {
          var that   = this;
          var picker = window.parent.application_view.content_assets_picker_view;

          picker.options.on_select = function(asset) {
            if (asset.get('image') == true)
              that.insertImg(asset);
            else
              that.insertLink(asset);

            picker.close();
          }

          picker.fetch_assets();
        },

        /**
        * This method will insert a new image dom element into the dom tree
        */
        insertImg: function(asset) {
          var range = Aloha.Selection.getRangeObject(),
          imageUrl  = asset.get('url'),
          imagestyle, imagetag, newImg;

          if (range.isCollapsed()) {
            imagestyle = "max-width: " + asset.get('width') + "; max-height: " + asset.get('height');
            imagetag = '<img style="'+ imagestyle + '" src="' + imageUrl + '" title="" />';
            newImg = jQuery(imagetag);
            GENTICS.Utils.Dom.insertIntoDOM(newImg, range, jQuery(Aloha.activeEditable.obj));
          } else {
            Aloha.Log.error('media cannot markup a selection');
          }
        },

        /**
        * This method will insert a new link dom element into the dom tree
        */
        insertLink: function(asset) {
          var range = Aloha.Selection.getRangeObject(),
          linkText  = asset.get('filename'),
          linkUrl   = asset.get('url'),
          linktag, newLink;

          if (range.isCollapsed()) {
            linktag = '<a href="' + linkUrl + '">' + linkText + '</a>';
            newLink = jQuery(linktag);
            GENTICS.Utils.Dom.insertIntoDOM(newLink, range, jQuery(Aloha.activeEditable.obj));
            range.startContainer = range.endContainer = newLink.contents().get(0);
            range.startOffset = 0;
            range.endOffset = linkText.length;
          } else {
            linktag = '<a href="' + linkUrl + '"></a>';
            newLink = jQuery(linktag);
            GENTICS.Utils.Dom.addMarkup(range, newLink, false);
          }
        },

        /**
         * Adds the insert button to the floating menu
         */
        _addUIInsertButton: function() {
          var that = this;
          var button = Ui.adopt('insertlocomotivemedia', Button, {
            tooltip: i18n.t('button.addimg.tooltip'),
            icon: 'aloha-button aloha-locomotive-media-insert',
            scope: 'Aloha.continuoustext',
            click: function(){ that.openDialog(); }
          });
        }

      });
  }
);