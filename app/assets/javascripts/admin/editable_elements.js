$(document).ready(function() {

  var enableNav = function() {
    $('#editable-elements .nav a').click(function(e) {
      var index = parseInt($(this).attr('href').match(/block-(.+)/)[1]);

      $('#editable-elements .wrapper ul li.block').hide();
      $('#block-' + index).show().find('fieldset').trigger('refresh');

      $(this).parent().find('.on').removeClass('on');
      $(this).addClass('on');

      e.preventDefault();
    });
  }

  enableNav();

  $.subscribe('form.saved.success', function(event, data) {
    if (data.editable_elements != '') {
      $('#editable-elements').replaceWith(data.editable_elements);
      enableNav();

      $('textarea.html').tinymce(TinyMceDefaultSettings);
    }
  }, []);

  $('textarea.html').tinymce(TinyMceDefaultSettings);

});
