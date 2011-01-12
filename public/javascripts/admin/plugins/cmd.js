$.cmd = function(key, callback, args, options) {
  var keyCode = key.charCodeAt(0);
  var altKeyCode = keyCode + (32 * (keyCode < 97 ? 1 : -1));

  options = (options || { ignoreCase: false });

  if (!options.ignoreCase) altKeyCode = null;

  $(document).keydown(function(e) {
    var isCtrl = false;

    if (!args) args = []; // IE barks when args is null

    if (e.ctrlKey || e.metaKey) isCtrl = true;

    if ((keyCode == e.which || altKeyCode == e.which) && isCtrl) {
      e.preventDefault();
      callback.apply(this, args);
      return false;
    }
  });

};