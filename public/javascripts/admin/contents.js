$(document).ready(function() {
	
	var updateContentsOrder = function() {
		var list = $('ul#contents-list.sortable');
		var ids = jQuery.map(list.sortable('toArray'), function(e) { 
			return e.match(/content-(\w+)/)[1];
		}).join(',');
		$('#order').val(ids || '');
	}

	$('ul#contents-list.sortable').sortable({
		handle: 'em',
		items: 'li.content',
		stop: function(event, ui) { updateContentsOrder(); }
	});
		
	$('button.edit-categories-link').click(function() {
		var link = $(this);
		$.fancybox({ 
			titleShow: false,
			href: link.attr('data-url'),
			padding: 0,
			onComplete: function() { SetupCustomFieldCategoryEditor(link.prev()); },
			onCleanup: function() { }
		})
	});
});