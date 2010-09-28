$(document).ready(function() {

  $('#import-steps').smartupdater({
    url : $('#import-steps').attr('data-url'),
    dataType: 'json',
    minTimeout: 100
  }, function(data) {
    var steps = ['site', 'content_types', 'assets', 'snippets', 'pages'];

    var currentIndex = data.step == 'done' ? steps.length - 1 : steps.indexOf(data.step);

    // console.log('data.step = ' + data.step + ', ' + currentIndex + ', ' + data.failed);

    for (var i = 0; i <= currentIndex; i++) {
      var state = 'done';

      if (i == currentIndex && data.failed) state = 'failed';

      $('#import-steps li:eq(' + i + ')').addClass(state);
    }

    // if (state == 'failed' || currentIndex == steps.length) # TODO
  });

});