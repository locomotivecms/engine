/**
 *
 * Copyright (c) 2009 Tony Dewan (http://www.tonydewan.com/)
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Project home:
 *   http://www.tonydewan.com/code/checkToggle/
 *
 */

(function($) {
  /**
   * Version 1.0
   * Replaces checkboxes with a toggle switch.
   * usage: $("input[type='checkbox']").checkToggle(settings);
   *
   * @name  checkToggle
   * @type  jquery
   * @param Hash    settings          Settings
   * @param String  settings[on_label]    Text used for the left-side (on) label. Defaults to "On"
   * @param String  settings[off_label]   Text used for the right-side (off) label. Defaults to "Off"
   * @param String  settings[on_bg_color]   Hex background color for On state
   * @param String  settings[off_bg_color]  Hex background color for Off state
   * @param String  settings[skin_dir]    Document relative (or absolute) path to the skin directory
   * @param Bool    settings[bypass_skin]   Flags whether to bypass the inclusion of the skin.css file.  Used if you've included the skin styles somewhere else already.
   */

    $.fn.checkToggle = function(settings) {

    settings = $.extend({
      on_label  : 'Yes',
      on_bg_color : '#8FE38D',
      off_label : 'No',
      off_bg_color: '#F8837C',
      skin_dir  : "skin/",
      bypass_skin : false
    }, settings);

    // FIXME (Didier Lafforgue) it works but it doesn't scale if we handle another locale
    if (typeof I18nLocale != 'undefined' && I18nLocale == 'fr') {
      settings.on_label = 'Oui';
      settings.off_label = 'Non';
    }

    // append the skin styles
    // if(settings.bypass_skin == false){
    //  $("head").append('<link type="text/css" rel="stylesheet" href="'+settings.skin_dir+'skin.css" media="screen" />');
    // }

    function toggle(element){

      var checked = $(element).parent().parent().prev().attr("checked");

      // if it's set to on
      if(checked){

        $(element).animate({marginLeft: '34px'}, 100,

        // callback function
        function(){
          $(element).parent().prev().css("color","#cccccc");
          $(element).parent().next().css("color","#333333");
          $(element).parent().css("background-color", settings.off_bg_color);
          $(element).parent().parent().prev().removeAttr("checked");
          $(element).removeClass("left").addClass("right");

          $.publish('toggle.' + $(element).parent().parent().prev().attr('id') + '.unchecked', []);
        });

      }else{

        $(element).animate({marginLeft: '0em'}, 100,

        // callback function
        function(){
          $(element).parent().prev().css("color","#333333");
          $(element).parent().next().css("color","#cccccc");
          $(element).parent().css("background-color", settings.on_bg_color);
          $(element).parent().parent().prev().attr("checked","checked");
          $(element).removeClass("right").addClass("left");

          $.publish('toggle.' + $(element).parent().parent().prev().attr('id') + '.checked', []);
        });

      }

    };

    return this.each(function () {

      if ($(this).hasClass('simple')) return;

      // hide the checkbox
      $(this).css('display','none');

      // insert the new toggle markup
      if($(this).attr("checked") == true){
        $(this).after('<div class="toggleSwitch"><span class="leftLabel">'+settings.on_label+'<\/span><div class="switchArea" style="background-color: '+settings.on_bg_color+'"><span class="switchHandle left" style="margin-left: 0em;"><\/span><\/div><span class="rightLabel" style="color:#cccccc">'+settings.off_label+'<\/span><\/div>');
      }else{
        $(this).after('<div class="toggleSwitch"><span class="leftLabel" style="color:#cccccc;">'+settings.on_label+'<\/span><div class="switchArea" style="background-color: '+settings.off_bg_color+'"><span class="switchHandle right" style="margin-left:34px"><\/span><\/div><span class="rightLabel">'+settings.off_label+'<\/span><\/div>');
      }

      // Bind the switchHandle click events to the internal toggle function
      $(this).next().find('div.switchArea').bind("click", function () {
        toggle($(this).find('.switchHandle')); })
    });


  };

})(jQuery);