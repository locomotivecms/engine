$(document).ready(function() {
	
	// open / close folder
	$('#pages-list ul.folder img.toggler').click(function(e) {
		var toggler = $(this);
		var children = toggler.parent().find('> ul.folder');
		if (children.is(':visible')) {
			children.slideUp('fast', function() {
				toggler.attr('src', toggler.attr('src').replace('open', 'closed'));
				$.cookie(children.attr('id'), 'none');
			});
		} else {
			children.slideDown('fast', function() {
				toggler.attr('src', toggler.attr('src').replace('closed', 'open'));
				$.cookie(children.attr('id'), 'block');
			});
		} 
	});
	
	// sortable folder items
	$('#pages-list ul.folder').sortable({ 
		'handle': 'em', 
		'axis': 'y',
		'update': function(event, ui) {
			var params = $(this).sortable('serialize', { 'key': 'children[]' });
			params += '&_method=put';
			
			$.post($(this).attr('data_url'), params, function(data) {
				$.growl('success', data.message);
			}, 'json');
		} 
	});
	
	// automatic slug from page title
	$('#page_title').keypress(function() {
		var input = $(this);
		var slug = $('#page_slug');
		
		if (!slug.hasClass('filled')) {
			setTimeout(function() {
				slug.val(makeSlug(input.val())).addClass('touched');
			}, 50);
		}
	});
	
	$('#page_slug').keypress(function() {
		$(this).addClass('filled').addClass('touched');
	});
	
	var lookForSlugAndUrl = function() {
		params = 'parent_id=' + $('#page_parent_id').val() + "&slug=" + $('#page_slug').val();
		$.get($('#page_slug').attr('data_url'), params, function(data) {
			$('#page_slug_input .inline-hints').html(data.url).effect('highlight');
		}, 'json');
	};	
	
	$('#page_parent_id').change(lookForSlugAndUrl);
	
	setInterval(function() {
		var slug = $('#page_slug');
		if (slug.hasClass('touched')) {
			slug.removeClass('touched');
			lookForSlugAndUrl();
		}
	}, 2000);
	
});