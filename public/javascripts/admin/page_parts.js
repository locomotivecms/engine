$(document).ready(function() {
	
	// slider 
	var resetSlider = function() {
		$('#page-parts .wrapper ul').wslide({
			width: 880,
			height: 400,
			autolink: false,
			duration: 300,
			horiz: true
		});
	}
	
	resetSlider();
	
	// codemirror
	$('#parts code textarea').each(function() { addCodeMirrorEditor('liquid', $(this)); });
		
	var refreshParts = function(parts) {
		// console.log('refreshParts');
		$('#page-parts .nav a').removeClass('enabled');
		
		$(parts).each(function() {
			// console.log("iterating..." + this.slug);
			var control = $('#control-part-' + this.slug);
			
			// adding missing part
			if (control.size() == 0) {
				// console.log('adding part');
				var nbParts = $('#page-parts .nav a').size();
				$('#page-parts .nav .clear').before('<a id="control-part-' + this.slug + '" class="enabled part-' + nbParts + '" href="#parts-' + (nbParts + 1) + '"><span>' + this.name + '</span></a>');
				
				var textareaInput = '<textarea rows="20" name="page[parts_attributes][' + nbParts + '][value]" id="page_parts_attributes_' + nbParts + '_value"/>';
				var hiddenInputs = '<input type="hidden" name="page[parts_attributes][' + nbParts + '][name]" value="' + this.name + '" />'
				hiddenInputs += '<input type="hidden" name="page[parts_attributes][' + nbParts + '][slug]" value="' + this.slug + '" />'
				$('#page-parts .wrapper ul').append('<li id="part-' + nbParts + '" class="new"><code>' + textareaInput + '</code>' + hiddenInputs +  '</li>');
				
				resetSlider();
				$('#parts li:last code textarea').each(function() { addCodeMirrorEditor('liquid', $(this)); });
			} else {
				var index = parseInt(control.attr('class').match(/part-(.+)/)[1]) + 1;
				var wrapper = $('#parts-' + index);
				
				// updating part
				control.html('<span>' + this.name + '</span>').addClass('enabled').show();
				wrapper.find('input.disabled').val('false');
				wrapper.show();
			}			
	 	});
	
		// removing or hiding parts
		$('#page-parts .nav a:not(.enabled)').each(function() {
			var index = parseInt($(this).attr('class').match(/part-(.+)/)[1]) + 1;
			var wrapper = $('#parts-' + index);
			if (wrapper.hasClass('new')) {
				$(this).remove(); wrapper.remove();
			} else {
				wrapper.find('input.disabled').val('true');
				$(this).hide(); wrapper.hide();
			}
		});
		
		// go to the first one if we hid the selected wrapper
		var selectedNav = $('#page-parts .nav a.on');
		if (selectedNav.size() == 1) {
			var index = parseInt(selectedNav.attr('class').match(/part-(.+)/)[1]) + 1;
			if ($('#parts-' + index + ':visible').size() == 0)
				$('#page-parts .nav a:first').click();
		} else
			$('#page-parts .nav a:first').click();
	}
		
	var loadPartsFromLayout = function() {
		if ($('#page_layout_id').val() == '')
			return ;
		
		var url = $('#page_layout_id').attr('data_url').replace('_id_to_replace_', $('#page_layout_id').val());
		$.get(url, '', function(data) { refreshParts(data.parts); }, 'json');
	}
		
	$('#page_layout_id').change(loadPartsFromLayout);
	
});