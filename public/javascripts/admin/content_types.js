$(document).ready(function() {
	
	// automatic slug from  name
	$('#content_type_name').keypress(function() {
		var input = $(this);
		var slug = $('#content_type_slug');
	
		if (!slug.hasClass('filled')) {
			setTimeout(function() {
				slug.val(makeSlug(input.val()));
			}, 50);
		}
	});
	
	$('#content_type_slug').keypress(function() { $(this).addClass('filled'); });
});