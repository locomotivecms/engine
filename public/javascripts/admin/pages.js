$(document).ready(function() {

  // open / close folder
  if (typeof $.fn.toggleMe != 'undefined')
    $('#pages-list ul.folder img.toggler').toggleMe();

  // sortable folder items
  $('#pages-list ul.folder').sortable({
    'handle': 'em',
    'axis': 'y',
    'update': function(event, ui) {
      var params = $(this).sortable('serialize', { 'key': 'children[]' });
      params += '&_method=put';
      params += '&' + $('meta[name=csrf-param]').attr('content') + '=' + $('meta[name=csrf-token]').attr('content');

      $.post($(this).attr('data-url'), params, function(data) {
        var error = typeof(data.error) != 'undefined';
        $.growl((error ? 'error' : 'success'), (error ? data.error : data.notice));
      }, 'json');
    }
  });

  // templatized feature

  $.subscribe('toggle.page_templatized.checked', function(event, data) {
    $('#page_slug_input').hide();
    $('#page_redirect').parent('li').hide();
    $('#page_listed').parent('li').hide();
    $('#page_content_type_id_input').show();
  }, []);

  $.subscribe('toggle.page_templatized.unchecked', function(event, data) {
    $('#page_slug_input').show();
    $('#page_redirect').parent('li').show();
    $('#page_listed').parent('li').show();
    $('#page_slug').val(makeSlug($('#page_title').val())).addClass('touched');
    $('#page_content_type_id_input').hide();
  }, []);

  // redirect feature

  var advancedSettingsFieldset = $('.formtastic.page fieldset#advanced-options');

  $.subscribe('toggle.page_redirect.checked', function(event, data) {
    $('#page_templatized').parent('li').hide();
    $('#page_cache_strategy_input').hide();
    $('#page_redirect_url_input').show();
    advancedSettingsFieldset.trigger('refresh');
  }, []);

 $.subscribe('toggle.page_redirect.unchecked', function(event, data) {
    $('#page_templatized').parent('li').show();
    $('#page_cache_strategy_input').show();
    $('#page_redirect_url_input').hide();
    advancedSettingsFieldset.trigger('refresh');
  }, []);

  // automatic slug from page title
  $('#page_title').keypress(function() {
    var input = $(this);
    var slug = $('#page_slug');

    if (!slug.hasClass('filled')) {
      setTimeout(function() {
        slug.val(makeSlug(input.val(), '-')).addClass('touched');
      }, 50);
    }
  });

  $('#page_slug').keypress(function() {
    $(this).addClass('filled').addClass('touched');
  });

  var lookForSlugAndUrl = function() {
    params = 'parent_id=' + $('#page_parent_id').val() + "&slug=" + $('#page_slug').val();
    $.get($('#page_slug').attr('data-url'), params, function(data) {
      $('#page_slug_input .inline-hints').html(data.url).effect('highlight');
    }, 'json');
  };

  $('#page_parent_id').change(lookForSlugAndUrl);

  setInterval(function() {
    var slug = $('#page_slug');
    if (slug.hasClass('touched')) {
      slug.removeClass('touched');
      lookForSlugAndUrl();
    }
  }, 2000);

  if (typeof $.fn.imagepicker != 'undefined')
    $('a#image-picker-link').imagepicker({
      insertFn: function(link) {
        return "{{ '/" + link.attr('data-local-path') + "' | theme_image_url }}";
      }
    });

});
