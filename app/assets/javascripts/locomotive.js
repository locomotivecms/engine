// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require turbolinks
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-sprockets
//= require underscore/underscore
//= require backbone/backbone
//= require bootstrap-tagsinput/bootstrap-tagsinput
//= require select2/select2
//= require moment/moment
//= require moment-timezone/moment-timezone
//= require eonasdan-bootstrap-datetimepicker/bootstrap-datetimepicker
//= require codemirror
//= require codemirror/modes/markdown
//= require nprogress
//= require nprogress-ajax
//= require locomotive/vendor
//= require ./locomotive/application

$(document).ready(function() {
  $.datepicker.setDefaults($.datepicker.regional[window.locale]);
});

document.addEventListener("turbolinks:load", function() {
  var view_class_name = $('meta[name=backbone-view]').attr('content');
  var flash_present   = parseInt($('meta[name=flash-messages-count]').attr('content')) > 0;

  console.log('[turbolinks:load] fired ' + view_class_name + ', ' + flash_present);

  window.application_view = new Locomotive.Views.ApplicationView({
    flash:  flash_present ? window.flash_messages : {},
    view:   stringToFunction(view_class_name)
  });

  window.application_view.render();
});

document.addEventListener("turbolinks:before-visit", function() {
  console.log('[turbolinks:before-visit] fired (cleaning)')
  window.application_view.view.remove();
});

