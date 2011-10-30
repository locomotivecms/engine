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
    var input_name = $('input#site_subdomain').attr('name').split('[')[0];
    var input = newRow.find('input.label')
      .attr('name', input_name + '[domains][]');
    if (lastRow.find('input.label').val() == '') input.val("undefined");

    // then reset and clean the form
    $('fieldset.editable-list input.empty-domains').remove();

    lastRow.find('input').val(defaultValue).addClass('void');
    lastRow.find('select').val('input');
  });

  $('fieldset.editable-list li a.remove').click(function(e) {
    if (confirm($(this).attr('data-confirm')))
      $(this).parents('li').remove();

    if ($('fieldset.editable-list .item.added').size() == 0)
      $('fieldset.editable-list').append('<input name="site[domains]" type="hidden" value="" class="empty-domains" />');

    e.preventDefault();
    e.stopPropagation();
  });

  $.subscribe('form.saved.success', function(event, data) {
    var value = $('#site_name').val();
    $('#header h1 a.single').html(value);
    $('#header h1 a span.ui-selectmenu-status').html(value);
    $('#site-selector-menu li.ui-selectmenu-item-selected a').html(value);
  }, []);

  // account roles
  $('.membership .role em.editable').click(function() {
    $(this).hide();
    $(this).next().show();
  });

  $('.membership .role select').each(function() {
    var select = $(this);
    select.hover(function() {
      clearTimeout($.data(select, 'timer'));
    },
    function() {
      $.data(select, 'timer', setTimeout(function() {
        select.hide();
        select.prev().show();
      }, 1000));
    }).change(function() {
      select.hide().prev()
        .show()
        .html(select[0].options[select[0].options.selectedIndex].text);
    });
  }).hide();


});
