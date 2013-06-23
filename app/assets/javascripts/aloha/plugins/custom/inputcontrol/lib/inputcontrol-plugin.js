/*!
* Aloha Editor
* Copyright (c) 2010 Gentics Software GmbH
* aloha-sales@gentics.com
* Author Nicolas Karageuzian
* Licensed unter the terms of http://www.aloha-editor.com/license.html
# https://github.com/temistokles/Aloha-Plugin-InputControl
*/

define(
['aloha/plugin', 'aloha'],
function (plugin, Aloha) {
  "use strict";

  /**
   * register the plugin with unique name
   */
  return plugin.create('inputcontrol', {
    _constructor: function(){
      this._super('inputcontrol');
    },
    /**
     * Initialize the plugin and set initialize flag on true
     */
    init: function () {
      var inputmask = this;
      inputmask.bindEvents();
    },

    config: {
      "enableFilter": false,
      "allowchars": new RegExp('.'), // allows any character (default)
      "enableMask": false
    },
    bindEvents: function() {
      var inputmask = this;
      Aloha.bind('aloha-editable-created', function(event, editable){
        var edConfig = inputmask.getEditableConfig(editable.obj);
        if (edConfig.enableFilter) {
        //filtering is enabled, watching keypress (to get the unicode charcode)
          editable.obj.keypress(function(event){ // listen for keypress (then get the unicode char)
            var
              k = event.which, chr,
              result = true;
            chr = String.fromCharCode(k);
            if (edConfig.allowchars instanceof RegExp){
              Aloha.Log.debug(Aloha, "Keycode : [" + k + "] char : '" + chr + "'");
              result = result && edConfig.allowchars.test(chr);
            }
            return result;
          });
        }
        if (edConfig.disableEnter) {
          editable.obj.unbind('keydown'); // unbinding aloha preprocess
          editable.obj.keydown(function(event) {
            if (event.keyCode === 13) {
              return false;
             }
            return true; //Aloha.Markup.preProcessKeyStrokes();
          });
        }
        if (edConfig.enableMask) { // TODO: debug in here
          editable.obj.blur(function (event){
            var $this = $(this);
            if (edConfig.type === Number) {
              if (new Number($this.text()).toString() === "NaN") {
                $this.addClass('aloha-input-invalid');
              } else {
                $this.removeClass('aloha-input-invalid');
              }
            }
            if (typeof edConfig.maxlength === "number") {
              if (edConfig.striphtml) {
                if ($this.text().length >= edConfig.maxlength) {
                  $this.addClass('aloha-input-invalid');
                } else {
                  $this.removeClass('aloha-input-invalid');
                }
              } else {
                if ($this.html().length >= edConfig.maxlength) {
                  $this.addClass('aloha-input-invalid');
                } else {
                  $this.removeClass('aloha-input-invalid');
                }
              }
            }
            return true;
          });
        }
      });
    }

  });
});