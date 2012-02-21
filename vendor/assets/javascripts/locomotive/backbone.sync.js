(function() {
  var methodMap = {
    'create': 'POST',
    'update': 'PUT',
    'delete': 'DELETE',
    'read'  : 'GET'
  };

  var getUrl = function(object) {
    if (!(object && object.url)) return null;
    return _.isFunction(object.url) ? object.url() : object.url;
  };

  var urlError = function() {
    throw new Error("A 'url' property or function must be specified");
  };

  Backbone.sync = function(method, model, options) {
    var type = methodMap[method];

    // Default JSON-request options.
    var params = _.extend({
      type:         type,
      dataType:     'json',
      beforeSend: function( xhr ) {
        var token = $('meta[name="csrf-token"]').attr('content');
        if (token) xhr.setRequestHeader('X-CSRF-Token', token);
      }
    }, options);

    if (!params.url) {
      params.url = getUrl(model) || urlError();
    }

    // Ensure that we have the appropriate request data.
    if (!params.data && model && (method == 'create' || method == 'update')) {
      params.contentType = 'application/json';

      var data = {}

      if(model.paramRoot) {
        data[model.paramRoot] = model.toJSON();
      } else {
        data = model.toJSON();
      }

      if (typeof(FormData) != 'undefined') { // XHR2
        var formData = new FormData();

        formData.append('xhr', true); // fix a bug with POW which happens to not like empty form
        if (typeof(window.content_locale) != 'undefined' && window.content_locale != '')
          formData.append('content_locale', window.content_locale);

        var _buildParams = function(prefix, obj, fn) { // code grabbed from jquery
          if (jQuery.isArray(obj)) {
            if (obj.length == 0) { // empty arrays
              fn(prefix, obj);
              return;
            }

            jQuery.each(obj, function(i, v) {
              if (/\[\]$/.test(prefix)) { // rbracket
                fn(prefix, v);
              } else {
                _buildParams(prefix + "[" + ( typeof v === "object" || jQuery.isArray(v) ? i : "" ) + "]", v, fn);
              }
            });
          } else if (obj != null && typeof obj === "object" && !(obj instanceof File)) {
            for (var name in obj) {
              _buildParams(prefix + "[" + name + "]", obj[name], fn);
            }
          } else {
            fn(prefix, obj);
          }
        }

        for (var prefix in data) {
          _buildParams(prefix, data[prefix], function(key, value) {
            // console.log('append ' + key + ', ' + value + ', is Array = ' + jQuery.isArray(value));
            if (jQuery.isArray(value) && value.length == 0)
              formData.append(key + '[]', '');
            else
              if (value != null)
                formData.append(key, value);
          });
        }

        params.data = formData;
        params.processData = false;
        params.contentType = false;
      } else {
        params.data = JSON.stringify(data);
      }
    }

    // Don't process data on a non-GET request.
    if (params.type !== 'GET') {
      params.processData = false;
    }

    params.complete = function(xhr, textStatus) {
      var noticeType = xhr.getResponseHeader('X-Message-Type');
      if (noticeType != null) {
        var growlType = noticeType == 'notice' ? 'notice' : 'alert'; // for now, only 2 kind of growl messages
        $.growl(noticeType, xhr.getResponseHeader('X-Message'));
      }
    }

    // Make the request.
    return $.ajax(params);
  }

}).call(this);
