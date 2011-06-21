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

    formElement = $(document.forms[0]);

    listElement = formElement.find('ul');

    $.getJSON('/admin/images.json', function(data) {
      $(data.images).each(function() {
        ext = this.url.split('.').pop().toLowerCase();
        if($.inArray(ext, ['gif','png','jpg','jpeg']) != -1) {
            self._addImage(this);
        }
        else {
          self._addFile(this);
        }
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

  insertImage: function(url) {
    var ed = tinyMCEPopup.editor, f = document.forms[0], nl = f.elements, v, args = {}, el;

    tinyMCEPopup.restoreSelection();

    // Fixes crash in Safari
    if (tinymce.isWebKit) ed.getWin().focus();

    tinymce.extend(args, { src : url });

    el = ed.selection.getNode();

    if (el && el.nodeName == 'IMG') {
     ed.dom.setAttribs(el, args);
    } else {
     ed.execCommand('mceInsertContent', false, '<img id="__mce_tmp" />', {skip_undo : 1});
     ed.dom.setAttribs('__mce_tmp', args);
     ed.dom.setAttrib('__mce_tmp', 'id', '');
     ed.undoManager.add();
    }

    tinyMCEPopup.close();
  },
  
  insertFile: function(url, name) {
    var ed = tinyMCEPopup.editor, f = document.forms[0], nl = f.elements, v, args = {}, el;

    tinyMCEPopup.restoreSelection();

    // Fixes crash in Safari
    if (tinymce.isWebKit) ed.getWin().focus();

    tinymce.extend(args, { href : url });

    el = ed.selection.getNode();

    if (el && el.nodeName == 'IMG') {
     ed.dom.setAttribs(el, args);
    } else {
     ed.execCommand('mceInsertContent', false, '<a id="__mce_tmp" >Download '+name+'</a>', {skip_undo : 1});
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
      runtimes : (jQuery.browser.webkit == true ? 'flash' : 'html5,flash'),
      // container: 'theme-images',
      browse_button : 'upload-link',
      max_file_size : '10mb',
      url : $('a#upload-link').attr('href'),
      flash_swf_url : '/javascripts/admin/plugins/plupload/plupload.flash.swf',
      multipart: true,
      multipart_params: multipartParams,
      filters : [
        { title : "Media files", extensions : "png,gif,jpg,jpeg,pdf,doc,docx,xls,xlsx,txt" },
      ]
    });

    uploader.bind('QueueChanged', function() {
      self.showSpinner('uploading');
      uploader.start();
    });

    uploader.bind('FileUploaded', function(up, file, response) {
      var json = JSON.parse(response.response);

      if (json.status == 'success') {
        
        ext = json.url.split('.').pop().toLowerCase();
        if($.inArray(ext, ['gif','png','jpg','jpeg']) != -1) {
            self._addImage(json);
        }
        else {
          self._addFile(json);
        }
 
      }

      self.hideSpinner();
    });

    uploader.init();
  },

  _addImage: function(data) {
    var self = this;

    var asset = $('ul li.new-asset')
      .clone()
      .insertBefore($('ul li.clear'))
      .addClass('asset');

    asset.find('h4 a').attr('href', data.url)
      .html(data.name)
      .bind('click', function(e) {
        self.insert(data.url);
        e.stopPropagation(); e.preventDefault();
      });

    asset.find('.image .inside img')
      .attr('src', data.vignette_url)
      .bind('click', function(e) {
        self.insertImage(data.url);
      });

    asset.find('.actions a')
      .attr('href', data.destroy_url)
      .bind('click', function(e) {
        if (confirm($(this).attr('data-confirm'))) {
          self.showSpinner('destroying');
          $(this).callRemote();
        }
        e.preventDefault(); e.stopPropagation();
      })
      .bind('ajax:success', function(event, data) {
        self._destroyImage(asset);
      });

    if ($('ul li.asset').length % 4 == 0)
      asset.addClass('last');

    asset.removeClass('new-asset');

    $('p.no-items').hide();

  },
  
  _addFile: function(data) {
    var self = this;

    var asset = $('ul li.new-asset')
      .clone()
      .insertBefore($('ul li.clear'))
      .addClass('asset');

    asset.find('h4 a').attr('href', data.url)
      .html(data.name)
      .bind('click', function(e) {
        self.insert(data.url);
        e.stopPropagation(); e.preventDefault();
      });

    asset.find('.image .inside')
      .html(data.url.substr( (data.url.lastIndexOf('.') +1) ))
      .bind('click', function(e) {
        self.insertFile(data.url, data.url.substr( (data.url.lastIndexOf('/') +1) ));
      });

    asset.find('.actions a')
      .attr('href', data.destroy_url)
      .bind('click', function(e) {
        if (confirm($(this).attr('data-confirm'))) {
          self.showSpinner('destroying');
          $(this).callRemote();
        }
        e.preventDefault(); e.stopPropagation();
      })
      .bind('ajax:success', function(event, data) {
        self._destroyImage(asset);
      });

    if ($('ul li.asset').length % 4 == 0)
      asset.addClass('last');

    asset.removeClass('new-asset');
    
    asset.find('.image').removeClass('image').addClass('icon media');

    $('p.no-items').hide();

  },  

  _destroyImage: function(asset) {
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