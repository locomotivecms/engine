/* ___ file or text ___ */

var enableFileOrTextToggling = function() {
	$('div.hidden').hide();
	
	$('span.alt').click(function(event) {
		event.preventDefault();

		if ($("div#file-selector").is(":hidden")) {
			$("div#text-selector").slideUp("normal", function() {
				$("div#file-selector").slideDown();
				$("input#theme_asset_performing_plain_text").val(false);
			});
    } else {
			$("div#file-selector").slideUp("normal", function() {
				$("div#text-selector").slideDown();
				$("input#theme_asset_performing_plain_text").val(true);
			});
    }
	});
}

var copyLinkToEditor = function(link, event) {
	var editor = CodeMirrorEditors[0].editor;
	var handle = editor.cursorLine(), position = editor.cursorPosition(handle).character;
	var text = 'url("' + link.attr('href') + '")';

	editor.insertIntoLine(handle, position, text);

	event.stopPropagation();
	event.preventDefault();
	
	$.fancybox.close();
}

var setupUploader = function() {
	var multipartParams = {};
	multipartParams[$('meta[name=csrf-param]').attr('content')] = $('meta[name=csrf-token]').attr('content');
	
	var uploader = new plupload.Uploader({
		runtimes : 'html5,flash',
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
			
			asset.find('h4 a').attr('href', json.url).html(json.name).bind('click', function(e) {
				copyLinkToEditor($(this), e);
			});
			asset.find('.image .inside img').attr('src', json.vignette_url);
			
			if ($('.asset-picker ul li.asset').length % 3 == 0)
				asset.addClass('last');
			
			asset.removeClass('new-asset');
			
			$('.asset-picker p.no-items').hide();
			
			$('.asset-picker ul').scrollTo($('li.asset:last'), 400);
		}
	});
		
	uploader.init();
}

$(document).ready(function() {
	enableFileOrTextToggling();
	
	$('code.stylesheet textarea').each(function() {
		addCodeMirrorEditor(null, $(this), ["tokenizejavascript.js", "parsejavascript.js", "parsecss.js"]);
	});
	$('code.javascript textarea').each(function() { 
		addCodeMirrorEditor(null, $(this), ["parsecss.js", "tokenizejavascript.js", "parsejavascript.js"]); 
	});
	
	$('select#theme_asset_content_type').bind('change', function() {
		var editor = CodeMirrorEditors[0].editor;
		editor.setParser($(this).val() == 'stylesheet' ? 'CSSParser' : 'JSParser');
	});
	
	$('a#asset-picker-link').fancybox({
		'onComplete': function() {
			setupUploader();
			
			$('ul.assets h4 a').bind('click', function(e) { copyLinkToEditor($(this), e); });
		}
	});
});