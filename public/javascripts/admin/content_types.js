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

  $('#content_type_order_by').change(function() {
    if ($(this).val() != '_position_in_list')
      $('#content_type_order_direction_input').show();
    else
      $('#content_type_order_direction_input').hide();
  });

  // api enabled ?

  // console.log('subscribing...');

  var lastFieldset = $('.formtastic.content_type fieldset').last();

  $.subscribe('toggle.content_type_api_enabled.checked', function(event, data) {
    // console.log('checked');
    $('#content_type_api_accounts_input').show();
    lastFieldset.trigger('refresh');
  }, []);

  $.subscribe('toggle.content_type_api_enabled.unchecked', function(event, data) {
    // console.log('unchecked');
    $('#content_type_api_accounts_input').hide();
    lastFieldset.trigger('refresh');
  }, []);

});
