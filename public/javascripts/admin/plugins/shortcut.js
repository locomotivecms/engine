// Save -> Command S (need a form)
jQuery.fn.saveWithShortcut = function() {
	
	var resetFormErrors = function(form) {
		jQuery('div.form-errors').remove();
		jQuery('div.formError').remove();
		jQuery('p.inline-errors').remove();
		form.find('li.error').removeClass('error');
	}
	
	// var updateFromWyMeditor = function() {
	// 	if (jQuery.wymeditors == undefined)
	// 		return;
	// 	var i = 0;
	// 	while (jQuery.wymeditors(i) != undefined) {
	// 		var editor = jQuery.wymeditors(i);
	// 		editor.box().prev().val(editor.html());
	// 		i++;
	// 	}
	// };
	
	var updateFromCodeMirror = function() {
		if (CodeMirror == undefined)
			return;		
		jQuery.each(CodeMirrorEditors, function() { 
			this.el.val(this.editor.getCode());
		});
	}
	
	var save = function(form) {
		$.post(form.attr('action'), form.serializeArray(), function(data) {
			onSaveCallback(form, data)
		}, 'json');
	};
	
	var onSaveCallback = function(form, data) {
		resetFormErrors(form);
	
		if (data.alert != undefined) {	
			$.growl('error', data.alert);
			for (var i = 0; i < data.errors.length; i++) {
				var type = data.errors[i][0], value = data.errors[i][1];
				var node = form.find('li:has(#' + data.model + '_' + type + ')');
				node.addClass('error');
				node.append("<p class='inline-errors'>" + value + "</p>");
			}
			form.find('li.error input').eq(0).focus();
		} else {
			$.growl('success', data.notice);
			// $.publish('form.saved.success', [data]);
		}
	};
	
	return this.each(function() {
		var form = jQuery(this);
		
		jQuery(document).bind('keypress.shortcut', function(event) {
			if (!(event.which == 115 && (event.ctrlKey || event.metaKey))) return true;
			// updateFromWyMeditor();
			updateFromCodeMirror();
			save(form);
			event.preventDefault();
			return false;
		});

	});
	
};
