// Save -> Command OR CTRL S/s (need a form)
jQuery.fn.saveWithShortcut = function() {

  var resetFormErrors = function(form) {
    jQuery('div.form-errors').remove();
    jQuery('div.formError').remove();
    jQuery('p.inline-errors').remove();
    form.find('li.error').removeClass('error');
  }

  var updateFromCodeMirror = function() {
    if (typeof CodeMirror == undefined) return;
    jQuery.each(CodeMirrorEditors, function() {
      this.el.val(this.editor.getCode());
    });
  }

  var save = function(form) {
    $.post(form.attr('action'), form.serializeArray(), function(data) {
      onSaveCallback(form, data)
    }, 'json');
  };

  var onSaveCallback = function(form, data) {
    resetFormErrors(form);

    if (data.alert != undefined) {
      $.growl('error', data.alert);
      for (var field in data.errors) {
        var error = data.errors[field];
        var node = form.find('li:has(#' + data.model + '_' + field + ')');
        node.addClass('error');
        node.append("<p class='inline-errors'>" + error + "</p>");
      }
      form.find('li.error input').eq(0).focus();
    } else {
      $.growl('success', data.notice);
      $.publish('form.saved.success', [data]);
    }
  };

  return this.each(function() {
    var form = jQuery(this);

    $.cmd('S', function() {
      updateFromCodeMirror();
      save(form);
    }, [], { ignoreCase: true });

  });

};
