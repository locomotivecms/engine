$(document).ready(function() {

  $('#editable-elements .nav a').click(function(e) {
    var index = parseInt($(this).attr('href').match(/block-(.+)/)[1]);

    $('#editable-elements .wrapper ul li.block').hide();
    $('#block-' + index).show();

    $(this).parent().find('.on').removeClass('on');
    $(this).addClass('on');

    e.preventDefault();
  });

});
