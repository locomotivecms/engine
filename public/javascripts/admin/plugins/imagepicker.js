$.fn.imagepicker = function(options) {

  var defaults = {
    insertFn: null
  };
  var options = $.extend(defaults, options);

  var copyLinkToEditor = function(link, event) {
    var editor = CodeMirrorEditors[0].editor;
    var handle = editor.cursorLine(), position = editor.cursorPosition(handle).character;

    var value = options.insertFn != null ? options.insertFn(link) : link.attr('href');

    editor.insertIntoLine(handle, position, value);

    event.stopPropagation();
    event.preventDefault();

    $.fancybox.close();
  }

  var setupUploader = function() {
    var multipartParams = {};
    multipartParams[$('meta[name=csrf-param]').attr('content')] = $('meta[name=csrf-token]').attr('content');

    var uploader = new plupload.Uploader({
      runtimes : (jQuery.browser.webkit == true ? 'flash' : 'html5,flash'),
      container: 'theme-images',
      browse_button : 'upload-link',
      max_file_size : '5mb',
      url : $('a#upload-link').attr('href'),
      flash_swf_url : '/javascripts/admin/plugins/plupload/plupload.flash.swf',
      multipart: true,
      multipart_params: multipartParams
    });

    uploader.bind('QueueChanged', function() {
      uploader.start();
    });

    uploader.bind('FileUploaded', function(up, file, response) {
      var json = JSON.parse(response.response);

      if (json.status == 'success') {
        var asset = $('.asset-picker ul li.new-asset')
          .clone()
          .insertBefore($('.asset-picker ul li.clear'))
          .addClass('asset');

        asset.find('strong a').attr('href', json.url)
          .attr('data-local-path', json.local_path)
          .html(json.local_path).bind('click', function(e) {
          copyLinkToEditor($(this), e);
        });
        asset.find('.more .size').html(json.size);
        asset.find('.more .date').html(json.date);

        if ($('.asset-picker ul li.asset').length % 3 == 0)
          asset.addClass('last');

        asset.removeClass('new-asset');

        $('.asset-picker p.no-items').hide();
      }
    });

    uploader.init();
  }

  return this.each(function() {
    $(this).fancybox({
      'onComplete': function() {
        setupUploader();

        $('ul.theme-assets strong a').bind('click', function(e) { copyLinkToEditor($(this), e); });
      }
    });
  });
};