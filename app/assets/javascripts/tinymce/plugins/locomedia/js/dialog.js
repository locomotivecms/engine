var MediafileDialog = {
  formElement: null,

  listElement: null,

  preInit : function() {
    var url;

    tinyMCEPopup.requireLangPack();

    if (url = tinyMCEPopup.getParam("external_image_list_url"))
      document.write('<script language="javascript" type="text/javascript" src="' + tinyMCEPopup.editor.documentBaseURI.toAbsolute(url) + '"></script>');
  },

  init : function(ed) {
    var self = this;

    with(window.parent) {
      var csrf_token = $('meta[name=csrf-token]').attr('content'),
          csrf_param = $('meta[name=csrf-param]').attr('content');
    }

    $.fn.setCsrfSettings(csrf_token, csrf_param);

    formElement = $(document.forms[0]);

    listElement = formElement.find('ul');

    $.getJSON('/admin/assets.json', function(data) {
      $(data.assets).each(function() {
        self._addAsset(this);
      });

      self.setupUploader();

      self.hideSpinner();

      if ($('ul li.asset').length == 0) $('p.no-items').show();
    });
  },

  hideSpinner: function() {
    $('#spinner').hide();
  },

  showSpinner: function(msg) {
    $('#spinner .text').hide();
    $('#spinner .' + msg).show();
    $('#spinner').show();
  },

  insertFile: function(asset) {
    var ed = tinyMCEPopup.editor, f = document.forms[0], nl = f.elements, v, args = {}, el;

    tinyMCEPopup.restoreSelection();

    // Fixes crash in Safari
    if (tinymce.isWebKit) ed.getWin().focus();

    if (asset.content_type == 'image')
      tinymce.extend(args, { src : asset.url });
    else
      tinymce.extend(args, { href : asset.url });

    el = ed.selection.getNode();

    if (el && (el.nodeName == 'IMG' || el.nodeName == 'A')) {
     ed.dom.setAttribs(el, args);
    } else {
      if (asset.content_type == 'image') {
        ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" />', { skip_undo: 1 });
      } else {
        var html = ed.selection.getContent();
        if (html == '') html = asset.filename;
        ed.execCommand('mceInsertContent', false, '<a id="__mce_tmp" >' + html + '</a>', { skip_undo: 1 });
      }


      ed.dom.setAttribs('__mce_tmp', args);
      ed.dom.setAttrib('__mce_tmp', 'id', '');
      ed.undoManager.add();
    }

    tinyMCEPopup.close();
  },

  setupUploader: function() {
    var self = this;
    var multipartParams = {};

    with(window.parent) {
      multipartParams[$('meta[name=csrf-param]').attr('content')] = $('meta[name=csrf-token]').attr('content');
    }

    var uploader = new plupload.Uploader({
      // runtimes : (jQuery.browser.webkit == true ? 'flash' : 'html5,flash'),
      runtimes: 'gears,html5,flash',
      browse_button : 'upload-link',
      max_file_size : '10mb',
      url : $('a#upload-link').attr('href'),
      flash_swf_url : '/javascripts/admin/plugins/plupload/plupload.flash.swf',
      multipart: true,
      multipart_params: multipartParams,
      filters : [
        { title : 'Media files', extensions : 'png,gif,jpg,jpeg,pdf,doc,docx,xls,xlsx,txt' },
      ]
    });

    uploader.bind('BeforeUpload', function(up, file) {
      file.name = unescape(encodeURIComponent(file.name));
      console.log(file.name);
    });

    uploader.bind('QueueChanged', function() {
      self.showSpinner('uploading');
      uploader.start();
    });

    uploader.bind('FileUploaded', function(up, file, response) {
      console.log(up);
      console.log(file);
      console.log(response);

      var json = JSON.parse(response.response);

      if (json.status == 'success')
        self._addAsset(json);

      self.hideSpinner();
    });

    uploader.init();
  },

  _addAsset: function(data) {
    var self = this;

    var asset = $('ul li.new-asset')
      .clone()
      .insertBefore($('ul li.clear'))
      .addClass('asset');

    asset.find('h4 a').attr('href', data.url)
      .html(data.short_name)
      .bind('click', function(e) {
        self.insertFile(data);
        e.stopPropagation(); e.preventDefault();
      });

    html = '';

    if (data.content_type == 'image') {
      asset.find('.icon').removeClass('icon').addClass('image');
      html = $('<img />')
        .attr('src', data.vignette_url)
        .bind('click', function(e) {
          self.insertFile(data);
        });
    } else {
      asset.find('.icon').addClass(data.content_type);
      html = data.content_type == 'other' ? data.extname : data.content_type;
      if (html == '') html = '?'
      html = $('<span />').html(html)
        .bind('click', function(e) {
          self.insertFile(data);
        });
    }

    asset.find('.inside').append(html);

    asset.find('.actions a')
      .attr('href', data.destroy_url)
      .bind('ajax:success', function(event, data) {
        self._destroyAsset(asset);
      });

    if ($('ul li.asset').length % 4 == 0)
      asset.addClass('last');

    asset.removeClass('new-asset');

    $('p.no-items').hide();
  },

  _destroyAsset: function(asset) {
    asset.remove();

    if ($('ul li.asset').length == 0) {
      $('p.no-items').show();
    } else {
      $('ul li.asset').each(function(index) {
        if ((index + 1) % 4 == 0)
          $(this).addClass('last');
        else
          $(this).removeClass('last');
      });
    }

    this.hideSpinner();
  }

};

MediafileDialog.preInit();
tinyMCEPopup.onInit.add(MediafileDialog.init, MediafileDialog);