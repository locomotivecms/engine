/**
 * Version 1.0
 * Init and deploy childs on menu (admin)
 * Benjamin Athlan - Bewcultures
 */
$.fn.toggleMe = function(settings) {

  settings = $.extend({
  }, settings);
  
  function toggle(element){
      var children = $(element).parent().find('> ul.folder');
        
          children.each(function(){
            if ($(this).is(':visible')) {
              $(this).slideUp('fast', function() {
                element.attr('src', element.attr('src').replace('open', 'closed'));
                $.cookie($(this).attr('id'), 'none');
              });
            } else {
              $(this).slideDown('fast', function() {
                element.attr('src', element.attr('src').replace('closed', 'open'));
                $.cookie($(this).attr('id'), 'block');
              });
            }
          });
  };
  
  return this.each(function(){
      toggle($(this));
    
    $(this).bind("click", function(){
      // console.log(this);
      toggle($(this));
    });
  });
  
};



