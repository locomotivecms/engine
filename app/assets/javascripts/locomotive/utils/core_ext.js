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
    var alphaNumRegexp = new RegExp('[^\\w\\' + sep + ']', 'g');
    var avoidDuplicateRegexp = new RegExp('[\\' + sep + ']{2,}', 'g');
    return this.replace(/\s/g, sep).replace(alphaNumRegexp, '').replace(avoidDuplicateRegexp, sep).toLowerCase();
  }

  window.addParameterToURL = function(key, value, context) { // code from http://stackoverflow.com/questions/486896/adding-a-parameter-to-the-url-with-javascript
    if (typeof context == 'undefined') context = document;

    key = encodeURIComponent(key); value = encodeURIComponent(value);

    var kvp = context.location.search.substr(1).split('&');

    var i = kvp.length; var x; while(i--) {
      x = kvp[i].split('=');

      if (x[0] == key) {
        x[1] = value;
        kvp[i] = x.join('=');
        break;
      }
    }

    if (i < 0) { kvp[kvp.length] = [key,value].join('='); }

    //this will reload the page, it's likely better to store this until finished
    context.location.search = kvp.join('&');
  }

  window.addJavascript = function(doc, src, options) {
    var script = doc.createElement('script');
    script.type = 'text/javascript';
    script.src = src;
    if (options && options.onload) {
      script.onload = options.onload;
      delete(options.onload);
    }
    for (var key in options) {
      script.setAttribute(key, options[key]);
    }
    doc.body.appendChild(script);
  }

  window.addStylesheet = function(doc, src, options) {
    var stylesheet = doc.createElement('link');
    stylesheet.style = 'text/css';
    stylesheet.href = src;
    stylesheet.media = 'screen';
    stylesheet.rel = 'stylesheet';
    doc.head.appendChild(stylesheet);
  }

  $.ui.dialog.prototype.overlayEl = function() { return this.overlay.$el; }

})();

