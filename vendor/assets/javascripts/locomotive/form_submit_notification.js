/**
 * Version 0.0.1
 * Display a message letting the user know the form is being submitted
 * Didier Lafforgue
 */
$.fn.formSubmitNotification = function(settings) {

  function show() {
    $('#form-submit-notification').fadeIn()
  }

  function hide() {
    $('#form-submit-notification').fadeOut()
  }

  function create(message) {
    if ($('#form-submit-notification').size() == 0) {
      var element = $("<div id=\"form-submit-notification\"><div>" + message + "</div></div>").hide();
      $('body').append(element);
    }
  }

  return this.each(function() {
    var form    = $(this);
    var message = form.attr('data-sending-form-message');

    if (typeof(message) == 'undefined')
      message = form.find('input[type=submit]').attr('data-sending-form-message');

    if (typeof(message) == 'undefined')
      return ;

    create(message);

    form.bind('ajax:beforeSend', function(event) { show() });
    form.bind('ajax:complete', function(event) { hide() });

  });
}