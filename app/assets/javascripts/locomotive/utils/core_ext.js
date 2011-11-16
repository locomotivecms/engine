(function() {
  String.prototype.trim = function() {
    return this.replace(/^\s+/g, '').replace(/\s+$/g, '');
  }

  String.prototype.repeat = function(num) {
    for (var i = 0, buf = ""; i < num; i++) buf += this;
    return buf;
  }

  String.prototype.truncate = function(length) {
    if (this.length > length) {
      return this.slice(0, length - 3) + "...";
    } else {
      return this;
    }
  }

  String.prototype.slugify = function(sep) {
    if (typeof sep == 'undefined') sep = '_';
    var alphaNumRegexp = new RegExp('[^a-zA-Z0-9\\' + sep + ']', 'g');
    var avoidDuplicateRegexp = new RegExp('[\\' + sep + ']{2,}', 'g');
    return this.replace(/\s/g, sep).replace(alphaNumRegexp, '').replace(avoidDuplicateRegexp, sep).toLowerCase()
  }
})();

