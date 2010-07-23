$(document).ready(function() {

  var defaultValue = $('fieldset.editable-list li.template input[type=text]').val();

  /* __ fields ___ */
  $('fieldset.editable-list li.template input[type=text]').focus(function() {
    if ($(this).hasClass('void') && $(this).parents('li').hasClass('template'))
      $(this).val('').removeClass('void');
  });

  $('fieldset.editable-list li.template button').click(function() {
    var lastRow = $(this).parents('li.template');

    var currentValue = lastRow.find('input.label').val();
    if (currentValue == defaultValue || currentValue == '') return;

    var newRow = lastRow.clone(true).removeClass('template').addClass('added').insertBefore(lastRow);

    // should copy the value of the select box
    var input = newRow.find('input.label')
      .attr('name', 'site[domains][]');
    if (lastRow.find('input.label').val() == '') input.val("undefined");

    // then reset the form
    lastRow.find('input').val(defaultValue).addClass('void');
    lastRow.find('select').val('input');
  });

  $('fieldset.editable-list li a.remove').click(function(e) {
    if (confirm($(this).attr('data-confirm')))
      $(this).parents('li').remove();
    e.preventDefault();
    e.stopPropagation();
  });

  $.subscribe('form.saved.success', function(event, data) {
    $('#header h1 a').html($('#current_site_name').val());
  }, []);
});
