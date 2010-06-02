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
	
	uploader.init();
}

$(document).ready(function() {
	enableFileOrTextToggling();
	
	// $('code.stylesheet textarea').each(function() {
	// 	addCodeMirrorEditor(null, $(this), ["tokenizejavascript.js", "parsejavascript.js", "parsecss.js"]);
	// });
	// $('code.javascript textarea').each(function() { 
	// 	addCodeMirrorEditor(null, $(this), ["parsecss.js", "tokenizejavascript.js", "parsejavascript.js"]); 
	// });
	
	$('select#theme_asset_content_type').bind('change', function() {
		var editor = CodeMirrorEditors[0].editor;
		editor.setParser($(this).val() == 'stylesheet' ? 'CSSParser' : 'JSParser');
	});
	
	$('a#asset-picker-link').fancybox({
		'onComplete': function() {
			setupUploader();
			
			$('ul.assets h4 a').bind('click', function(e) {
				var editor = CodeMirrorEditors[0].editor;
				var handle = editor.cursorLine(), position = editor.cursorPosition(handle).character;
				var text = 'url("' + $(this).attr('href') + '")';

				editor.insertIntoLine(handle, position, text);

				e.stopPropagation();
				e.preventDefault();
				
				$.fancybox.close();
			});
		}
	});
	
	$('a#asset-picker-link').click();
});