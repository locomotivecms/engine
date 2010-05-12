$(document).ready(function() {
	
	// automatic slug from snippet name
	$('#snippet_name').keypress(function() {
		var input = $(this);
		var slug = $('#snippet_slug');
	
		if (!slug.hasClass('filled')) {
			setTimeout(function() {
				slug.val(input.val().replace(/\s/g, '_').toLowerCase());
			}, 50);
		}
	});
	
	$('#snippet_slug').keypress(function() { $(this).addClass('filled'); });
});