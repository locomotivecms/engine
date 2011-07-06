$(document).ready(function() {

  $('#import-steps').smartupdater({
    url : $('#import-steps').attr('data-url'),
    dataType: 'json',
    minTimeout: 100
  }, function(data) {
    var steps = ['site', 'content_types', 'assets', 'snippets', 'pages'];

    var currentIndex = data.step == 'done' ? steps.length - 1 : steps.indexOf(data.step);

    for (var i = 0; i < steps.length; i++) {
      var state = null;

      if (i <= currentIndex) state = 'done';
      if (i == currentIndex + 1 && data.failed) state = 'failed';

      if (state != null)
        $('#import-steps li:eq(' + i + ')').addClass(state);
    }

    if (data.step == 'done')
      $.growl('notice', $('#import-steps').attr('data-success-message'));

    if (data.failed)
      $.growl('alert', $('#import-steps').attr('data-failure-message'));

    if (data.step == 'done' || data.failed)
      $('#import-steps').smartupdaterStop();
  });

});