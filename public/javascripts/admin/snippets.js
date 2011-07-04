$(document).ready(function() {

  // automatic slug from snippet name
  $('#snippet_name').keypress(function() {
    var input = $(this);
    var slug = $('#snippet_slug');

    if (!slug.hasClass('filled')) {
      setTimeout(function() {
        slug.val(makeSlug(input.val()));
      }, 50);
    }
  });

  $('#snippet_slug').keypress(function() { $(this).addClass('filled'); });

  $('a#image-picker-link').imagepicker({
    insertFn: function(link) {
      return "{{ '/" + link.attr('data-local-path') + "' | theme_image_url }}";
    }
  });
});
