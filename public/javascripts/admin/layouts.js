$(document).ready(function() {
  $('a#image-picker-link').imagepicker({
    insertFn: function(link) {
      return "{{ theme_images." + link.attr('data-slug') + " }}";
    }
  });
});
