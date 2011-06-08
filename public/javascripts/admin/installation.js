$(document).ready(function() {

  $('#default_site_template_input label a').click(function(e) {
    $('#default_site_template_input input[type=checkbox]').attr('checked', '');
    $('#default_site_template_input').hide();
    $('#zipfile_input').show();
    e.preventDefault();
  });

  $('#zipfile_input p.inline-hints a').click(function(e) {
    $('#default_site_template_input input[type=checkbox]').attr('checked', 'checked');
    $('#zipfile_input').hide();
    $('#default_site_template_input').show();
    e.preventDefault();
  });

});