$.cmd = function(key, callback, args) {
    var isCtrl = false;
    $(document).keydown(function(e) {
      if(!args) args=[]; // IE barks when args is null
      if(e.metaKey) isCtrl = true;
      if(e.keyCode == key.charCodeAt(0) && isCtrl) {
        callback.apply(this, args);
        return false;
      }
    }).keyup(function(e) {
        if(e.ctrlKey) isCtrl = false;
    });
};