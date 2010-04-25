var I18nLocale = null;

/* ___ growl ___ */

$.growl.settings.noticeTemplate = '' +
	'<div class="notice %title%">' +
	'  <p>%message%</p>' +
	'</div>';
	
$.growl.settings.dockCss = {
	position: 'fixed',
	bottom: '20px',
	left: '0px',
	width: '100%',
	zIndex: 50000
};

/* ___ global ___ */

$(document).ready(function() {
	I18nLocale = $('meta[name=locale]').attr('content');
	
	// form
	$('.formtastic li input, .formtastic li textarea').focus(function() {
		$('.formtastic li.error p.inline-errors').fadeOut(200);
		if ($(this).parent().hasClass('error')) {
			$(this).nextAll('p.inline-errors').show();
		}				
	});
	$('.formtastic li.error input').eq(0).focus();
	
	// editable title (page, ...etc)
	$('#content h2 a.editable').each(function() {
		var target = $('#' + $(this).attr('rel')), 
		hint = $(this).attr('title');
		
		target.parent().hide();
		
		$(this).click(function(event) {
			var newValue = prompt(hint, $(this).html());
			if (newValue && newValue != '') {
				$(this).html(newValue);
				target.val(newValue);
			}
			event.preventDefault();
		});
	});
	
	// foldable
	$('.formtastic fieldset.foldable legend span').append('<em>&nbsp;</em>');
	$('.formtastic fieldset.foldable.folded ol').hide();	
	$('.formtastic fieldset.foldable legend').click(function() {
		var parent = $(this).parent(), content = $(this).next();
		if (parent.hasClass('folded')) {
			parent.removeClass('folded');
			content.slideDown(400, function() {  });
		} else
			content.slideUp(400, function() { parent.addClass('folded'); });
	});
	
	// nifty checkboxes	
	$('.formtastic li.toggle input[type=checkbox]').checkToggle();
});