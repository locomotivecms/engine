$(document).ready(function() {
  $.subscribe('form.saved.success', function(event, data) {
    $('#global-actions-bar a:first').html($('#my_account_name').val());
  }, []);
});
