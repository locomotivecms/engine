if (typeof window.console === 'undefined') {
  window.console = { log: function() { return false; } };
}

function makeSlug(val, sep) { // code largely inspired by http://www.thewebsitetailor.com/jquery-slug-plugin/
  if (typeof val == 'undefined') return('');
  if (typeof sep == 'undefined') sep = '_';
  var alphaNumRegexp = new RegExp('[^a-zA-Z0-9\\' + sep + ']', 'g');
  var avoidDuplicateRegexp = new RegExp('[\\' + sep + ']{2,}', 'g');
  val = val.replace(/\s/g, sep);
  val = val.replace(alphaNumRegexp, '');
  val = val.replace(avoidDuplicateRegexp, sep);
  return val.toLowerCase();
}

(function() {
  String.prototype.trim = function() {
    return this.replace(/^\s+/g, '').replace(/\s+$/g, '');
  }

  String.prototype.repeat = function(num) {
    for (var i = 0, buf = ""; i < num; i++) buf += this;
    return buf;
  }
})();

Object.size = function(obj) {
  var size = 0, key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) size++;
  }
  return size;
};