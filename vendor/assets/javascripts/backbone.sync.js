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

        var _buildParams = function(prefix, obj, fn) { // code grabbed from jquery
          if (jQuery.isArray(obj)) {
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
            // console.log('append ' + key + ', ' + value);
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

    // Make the request.
    return $.ajax(params);
  }

}).call(this);
