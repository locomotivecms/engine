// edit category collection
$(document).ready(function() {
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

var SetupCustomFieldCategoryEditor = function(target) {
	
	var refreshPosition = function() {
		jQuery.each($('#edit-custom-field-category .editable-list li.added input.position'), function(index) { 
			$(this).val(index);
		});
	};
	
	$('#edit-custom-field-category .editable-list li.template button').click(function() {
		var lastRow = $(this).parents('li.template');
		
		if (lastRow.find('input.name').val() == '') return ;
		
		var newRow = lastRow.clone(true).removeClass('template').addClass('added new').insertBefore(lastRow);
	
		var dateFragment = '[' + new Date().getTime() + ']';
		newRow.find('input, select').each(function(index) {
			$(this).attr('name', $(this).attr('name').replace('[-1]', dateFragment));
		});
	
		// then reset the form
		lastRow.find('input').val('');
	
		// warn the sortable widget about the new row
		$("#edit-custom-field-category .editable-list ol").sortable('refresh');
		refreshPosition();
		
		// resize popup
		$.fancybox.resize();
	});
	
	$('#edit-custom-field-category .editable-list li a.remove').click(function(e) {
		if (confirm($(this).attr('data-confirm'))) {
			var parent = $(this).parents('li');
			if (parent.hasClass('new'))
				parent.remove();
			else {
				var field = parent.find('input.position')
				field.attr('name', field.attr('name').replace('[position]', '[_destroy]'));
				parent.hide().removeClass('added');
			}
			refreshPosition();
		}
		e.preventDefault();
		e.stopPropagation();
	});
	
	$("#edit-custom-field-category .editable-list ol").sortable({ 
		handle: 'span.handle', 
		items: 'li:not(.template)', 
		axis: 'y',
		update: refreshPosition
	});
	
	/* ___ submit ___ */
	
	var updateSelectOptions = function(list) {
		var options = '';
		var selectedValue = target.val();
		for (var i = 0; i < list.length; i++) {
			options += '<option value="' + list[i]._id + '" >' + list[i].name + '</option>';
		}
		target.html(options);
		target.val(selectedValue);
	};
	
	$('#edit-custom-field-category .popup-actions button').click(function(e) {
		var form = $('#edit-custom-field-category form');
		
		$.ajax({
			type: 'PUT',
			dataType: 'json',
			data: form.serialize(),
			url: form.attr('action'),
			success: function(data) {
				if (data.error == null) {
					list = data.category_items.sort(function(a, b) { return (a.position - b.position); });
					updateSelectOptions(list);
					$.fancybox.close();
				} else
					$.growl("error", data.error);
			}
		});
		e.preventDefault();
		e.stopPropagation();
	});
}