/**
 * Version 0.0.1
 * Catch the CTRL+S keys combination and trigger a callback
 * Didier Lafforgue
 */

$.cmd = function(key, callback, args, options) {
  var keyCode = key.charCodeAt(0);
  var altKeyCode = keyCode + (32 * (keyCode < 97 ? 1 : -1));

  options = (options || { ignoreCase: false });

  if (!options.ignoreCase) altKeyCode = null;

  doc = options.document || window.document;

  $(doc).keydown(function(e) {
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