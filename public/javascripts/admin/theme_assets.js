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

$(document).ready(function() {
	enableFileOrTextToggling();
	
	$('code.stylesheet textarea').each(function() { addCodeMirrorEditor('css', $(this)); });
	$('code.javascript textarea').each(function() { 
		addCodeMirrorEditor('javascript', $(this), ["tokenizejavascript.js", "parsejavascript.js"]); 
	});
});