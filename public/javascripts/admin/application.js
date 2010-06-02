var I18nLocale = null;
var CodeMirrorEditors = [];

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

/* ___ codemirror ___ */

var addCodeMirrorEditor = function(type, el, parser) {
	var parserfile = "parse" + type + ".js";
	if (parser != undefined) parserfile = parser;
	// if (type == 'liquid') type = 'xml';
	
	var editor = CodeMirror.fromTextArea(el.attr('id'), {
		height: "400px",
		parserfile: parserfile,
		stylesheet: [
			"/stylesheets/admin/plugins/codemirror/csscolors.css", 
			"/stylesheets/admin/plugins/codemirror/javascriptcolors.css", 
			"/stylesheets/admin/plugins/codemirror/liquidcolors.css"],
		path: "/javascripts/admin/plugins/codemirror/",
		continuousScanning: 500,
		reindentOnLoad: true,
		initCallback: function(editor) {
			jQuery(editor.frame.contentDocument).keypress(function(event) {
				jQuery(document).trigger(event);
			});
		}
	});
	CodeMirrorEditors.push({ 'el': el, 'editor': editor });
}

/* ___ global ___ */

$(document).ready(function() {
	I18nLocale = $('meta[name=locale]').attr('content');
	
	// sub menu links
	$('#submenu ul li.links').hover(function() {
		$(this).addClass('hover');
		$(this).find('.popup').show();
	}, function() {
		$(this).removeClass('hover');
		$(this).find('.popup').hide();
	});
	
	if ((css = $('#submenu > ul').attr('class')) != '')
		$('#submenu > ul > li.' + css).addClass('on');
	
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
			content.slideDown('fast', function() {  });
		} else
			content.slideUp('fast', function() { parent.addClass('folded'); });
	});
	
	// nifty checkboxes	
	$('.formtastic li.toggle input[type=checkbox]').checkToggle();
	
	// nifty code editor
	$('code.html textarea').each(function() { addCodeMirrorEditor('liquid', $(this)); });
});