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

  // api enabled ?

  console.log('subscribing...');

  $.subscribe('toggle.content_type_api_enabled.checked', function(event, data) {
    console.log('checked');
    $('#content_type_api_accounts_input').show();
  }, []);

  $.subscribe('toggle.content_type_api_enabled.unchecked', function(event, data) {
    console.log('unchecked');
    $('#content_type_api_accounts_input').hide();
  }, []);


});
