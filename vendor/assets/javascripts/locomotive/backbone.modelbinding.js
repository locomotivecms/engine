// Backbone.ModelBinding v0.4.1
//
// Copyright (C)2011 Derick Bailey, Muted Solutions, LLC
// Distributed Under MIT Liscene
//
// WARNING: Modified by Didier Lafforgue for LocomotiveCMS
//
// Documentation and Full Licence Availabe at:
// http://github.com/derickbailey/backbone.modelbinding

// ----------------------------
// Backbone.ModelBinding
// ----------------------------

Backbone.ModelBinding = (function(Backbone, _, $){
  modelBinding = {
    version: "0.4.1",

    bind: function(view, options){
      view.modelBinder = new ModelBinder(view, options);
      view.modelBinder.bind();
    },

    unbind: function(view){
      if (view.modelBinder){
        view.modelBinder.unbind()
      }
    }
  };

  ModelBinder = function(view, options){
    this.config = new modelBinding.Configuration(options);
    this.modelBindings = [];
    this.elementBindings = [];

    this.bind = function(){
      var conventions = modelBinding.Conventions;
      for (var conventionName in conventions){
        if (conventions.hasOwnProperty(conventionName)){
          var conventionElement = conventions[conventionName];
          var handler = conventionElement.handler;
          var conventionSelector = conventionElement.selector;
          handler.bind.call(this, conventionSelector, view, view.model, this.config);
        }
      }
    }

    this.unbind = function(){
      // unbind the html element bindings
      _.each(this.elementBindings, function(binding){
        binding.element.unbind(binding.eventName, binding.callback);
      });

      // unbind the model bindings
      _.each(this.modelBindings, function(binding){
        binding.model.unbind(binding.eventName, binding.callback);
      });
    }

    this.registerModelBinding = function(model, attribute_name, callback){
      // bind the model changes to the form elements
      var eventName = "change:" + attribute_name;
      model.bind(eventName, callback);
      this.modelBindings.push({model: model, eventName: eventName, callback: callback});
    }

    this.registerElementBinding = function(element, callback, callbackSilently){
      // bind the form changes to the model
      element.bind("change", callback);
      this.elementBindings.push({element: element, eventName: "change", callback: callback});

      if (callbackSilently)
        element.bind("changeSilently", callbackSilently)
    }
  }

  // ----------------------------
  // Model Binding Configuration
  // ----------------------------
  modelBinding.Configuration = function(options){
    this.bindingAttrConfig = {};

    _.extend(this.bindingAttrConfig,
      modelBinding.Configuration.bindindAttrConfig,
      options
    );

    if (this.bindingAttrConfig.all){
      var attr = this.bindingAttrConfig.all;
      delete this.bindingAttrConfig.all;
      for (var inputType in this.bindingAttrConfig){
        if (this.bindingAttrConfig.hasOwnProperty(inputType)){
          this.bindingAttrConfig[inputType] = attr;
        }
      }
    }

    this.getBindingAttr = function(type){
      return this.bindingAttrConfig[type];
    };

    this.getBindingValue = function(element, type){
      var bindingAttr = this.getBindingAttr(type);
      return element.attr(bindingAttr);
    };

  };

  modelBinding.Configuration.bindindAttrConfig = {
    text: "id",
    textarea: "id",
    password: "id",
    radio: "name",
    checkbox: "id",
    select: "id",
    number: "id",
    range: "id",
    tel: "id",
    search: "id",
    url: "id",
    email: "id"

  };

  modelBinding.Configuration.store = function(){
    modelBinding.Configuration.originalConfig = _.clone(modelBinding.Configuration.bindindAttrConfig);
  };

  modelBinding.Configuration.restore = function(){
    modelBinding.Configuration.bindindAttrConfig = modelBinding.Configuration.originalConfig;
  };

  modelBinding.Configuration.configureBindingAttributes = function(options){
    if (options.all){
      this.configureAllBindingAttributes(options.all);
      delete options.all;
    }
    _.extend(modelBinding.Configuration.bindindAttrConfig, options);
  };

  modelBinding.Configuration.configureAllBindingAttributes = function(attribute){
    var config = modelBinding.Configuration.bindindAttrConfig;
    config.text = attribute;
    config.textarea = attribute;
    config.password = attribute;
    config.radio = attribute;
    config.checkbox = attribute;
    config.select = attribute;
    config.number = attribute;
    config.range = attribute;
    config.tel = attribute;
    config.search = attribute;
    config.url = attribute;
    config.email = attribute;
  };

  // ----------------------------
  // Text, Textarea, and Password Bi-Directional Binding Methods
  // ----------------------------
  StandardBinding = (function(Backbone){
    var methods = {};

    var _getElementType = function(element) {
      var type = element[0].tagName.toLowerCase();
      if (type == "input"){
        type = element.attr("type");
        if (type == undefined || type == ''){
          type = 'text';
        }
      }
      return type;
    };

    methods.bind = function(selector, view, model, config){
      var modelBinder = this;

      view.$(selector).each(function(index){
        var element = view.$(this);
        var elementType = _getElementType(element);
        var attribute_name = config.getBindingValue(element, elementType);

        // HACK (Did)
        if (model.paramRoot) {
          regexp = new RegExp('^' + model.paramRoot + '_')
          attribute_name = attribute_name.replace(regexp, '')
        }
        // console.log(attribute_name);

        var modelChange = function(changed_model, val){
          val = val == null ? '' : val;
          element.val(val);
        };

        var setModelValue = function(attr_name, value, silent){
          if (typeof(silent) === 'undefined' || silent == null) silent = false
          var data = {};
          data[attr_name] = value;
          model.set(data, { 'silent': silent });
        };

        var elementChange = function(ev){
          setModelValue(attribute_name, view.$(ev.target).val());
        };

        // FIXME (Did): simple solution to update the model without triggering related callbacks (solving a bug with tinymce)
        var elementChangeSilently = function(ev) {
          setModelValue(attribute_name, view.$(ev.target).val(), true);
        }

        modelBinder.registerModelBinding(model, attribute_name, modelChange);
        modelBinder.registerElementBinding(element, elementChange, elementChangeSilently);

        // set the default value on the form, from the model
        var attr_value = model.get(attribute_name);
        if (typeof attr_value !== "undefined" && attr_value !== null) {
          element.val(attr_value);
        } else {
          var elVal = element.val();
          if (elVal){
            setModelValue(attribute_name, elVal);
          }
        }
      });
    };

    return methods;
  })(Backbone);

  // ----------------------------
  // Select Box Bi-Directional Binding Methods
  // ----------------------------
  SelectBoxBinding = (function(Backbone){
    var methods = {};

    methods.bind = function(selector, view, model, config){
      var modelBinder = this;

      view.$(selector).each(function(index){
        var element = view.$(this);
        var attribute_name = config.getBindingValue(element, 'select');

        // HACK (Did)
        if (model.paramRoot) {
          regexp = new RegExp('^' + model.paramRoot + '_')
          attribute_name = attribute_name.replace(regexp, '')
        }
        // console.log(attribute_name);

        var modelChange = function(changed_model, val){ element.val(val); };

        var setModelValue = function(attr, val, text){
          var data = {};
          data[attr] = val;
          data[attr + "_text"] = text;
          model.set(data);
        };

        var elementChange = function(ev){
          var targetEl = view.$(ev.target);
          var value = targetEl.val();
          var text = targetEl.find(":selected").text();
          setModelValue(attribute_name, value, text);
        };

        modelBinder.registerModelBinding(model, attribute_name, modelChange);
        modelBinder.registerElementBinding(element, elementChange);

        // set the default value on the form, from the model
        var attr_value = model.get(attribute_name);
        if (typeof attr_value !== "undefined" && attr_value !== null) {
          element.val(attr_value);
        }

        // set the model to the form's value if there is no model value
        if (element.val() != attr_value) {
          var value = element.val();
          var text = element.find(":selected").text();
          setModelValue(attribute_name, value, text);
        }
      });
    };

    return methods;
  })(Backbone);

  // ----------------------------
  // Radio Button Group Bi-Directional Binding Methods
  // ----------------------------
  RadioGroupBinding = (function(Backbone){
    var methods = {};

    methods.bind = function(selector, view, model, config){
      var modelBinder = this;

      var foundElements = [];
      view.$(selector).each(function(index){
        var element = view.$(this);

        var group_name = config.getBindingValue(element, 'radio');

        // HACK (Did)
        var attribute_name = group_name;
        if (model.paramRoot) {
          regexp = new RegExp('^' + model.paramRoot + "\\[");
          attribute_name = attribute_name.replace(regexp, '').replace(/\]$/, '');
        }
        // console.log(attribute_name);
        // console.log(group_name);

        if (!foundElements[group_name]) {
          foundElements[group_name] = true;
          var bindingAttr = config.getBindingAttr('radio');

          var modelChange = function(model, val){
            var value_selector = "input[type=radio][" + bindingAttr + "=" + group_name + "][value=" + val + "]";
            view.$(value_selector).attr("checked", "checked");
          };
          modelBinder.registerModelBinding(model, group_name, modelChange);

          var setModelValue = function(attr, val){
            var data = {};
            data[attr] = val;
            model.set(data);
          };

          // bind the form changes to the model
          var elementChange = function(ev){
            var element = view.$(ev.currentTarget);
            if (element.is(":checked")){
              setModelValue(attribute_name, element.val());
            }
          };

          var group_selector = "input[type=radio][" + bindingAttr + "=" + group_name + "]";
          view.$(group_selector).each(function(){
            var groupEl = $(this);
            modelBinder.registerElementBinding(groupEl, elementChange);
          });

          var attr_value = model.get(attribute_name);
          if (typeof attr_value !== "undefined" && attr_value !== null) {
            // set the default value on the form, from the model
            var value_selector = "input[type=radio][" + bindingAttr + "=" + group_name + "][value=" + attr_value + "]";
            view.$(value_selector).attr("checked", "checked");
          } else {
            // set the model to the currently selected radio button
            var value_selector = "input[type=radio][" + bindingAttr + "=" + group_name + "]:checked";
            var value = view.$(value_selector).val();
            setModelValue(attribute_name, value);
          }
        }
      });
    };

    return methods;
  })(Backbone);

  // ----------------------------
  // Checkbox Bi-Directional Binding Methods
  // ----------------------------
  CheckboxBinding = (function(Backbone){
    var methods = {};

    methods.bind = function(selector, view, model, config){
      var modelBinder = this;

      view.$(selector).each(function(index){
        var element = view.$(this);
        var bindingAttr = config.getBindingAttr('checkbox');
        var attribute_name = config.getBindingValue(element, 'checkbox');

        // HACK (Did)
        if (model.paramRoot) {
          regexp = new RegExp('^' + model.paramRoot + '_')
          attribute_name = attribute_name.replace(regexp, '')
        }
        // console.log(attribute_name);

        var isArray = _.isArray(model.get(attribute_name))

        var modelChange = function(model, val){
          var checked = val;
          if (isArray)
            checked = _.include(val, element.val());

          if (checked)
            element.attr("checked", "checked");
          else
            element.removeAttr("checked");
        };

        var setModelValue = function(attr_name, checked, value){
          var data = {};
          if (isArray) {
            var array = model.get(attr_name);
            if (array == null) array = [];
            if (checked)
              array.push(value);
            else
              array = _.without(array, value);
            data[attr_name] = array;
          } else
            data[attr_name] = checked;
          model.set(data);
        };

        var elementChange = function(ev){
          // console.log('[CHECKBOX] elementChange');
          var changedElement = view.$(ev.target);
          var checked = changedElement.is(":checked")? true : false;
          setModelValue(attribute_name, checked, changedElement.val());
        };

        modelBinder.registerModelBinding(model, attribute_name, modelChange);
        modelBinder.registerElementBinding(element, elementChange);

        var attr_exists = model.attributes.hasOwnProperty(attribute_name);
        if (attr_exists) {
          // set the default value on the form, from the model
          var attr_value = model.get(attribute_name);
          if (isArray && !_.isArray(attr_value)) attr_value = [];
          if (typeof attr_value !== "undefined" && attr_value !== null && (attr_value == true || _.include(attr_value, element.val()))) {
            element.attr("checked", "checked");
          }else{
            element.removeAttr("checked");
          }
        } else {
          // console.log('// bind the form\'s value to the model');
          // bind the form's value to the model
          var checked = element.is(":checked")? true : false;
          setModelValue(attribute_name, checked, element.val());
        }
      });
    };

    return methods;
  })(Backbone);

  // ----------------------------
  // Data-Bind Binding Methods
  // ----------------------------
  DataBindBinding = (function(Backbone, _, $){
    var dataBindSubstConfig = {
      "default": ""
    };

    modelBinding.Configuration.dataBindSubst = function(config){
      this.storeDataBindSubstConfig();
      _.extend(dataBindSubstConfig, config);
    };

    modelBinding.Configuration.storeDataBindSubstConfig = function(){
      modelBinding.Configuration._dataBindSubstConfig = _.clone(dataBindSubstConfig);
    };

    modelBinding.Configuration.restoreDataBindSubstConfig = function(){
      if (modelBinding.Configuration._dataBindSubstConfig){
        dataBindSubstConfig = modelBinding.Configuration._dataBindSubstConfig;
        delete modelBinding.Configuration._dataBindSubstConfig;
      }
    };

    modelBinding.Configuration.getDataBindSubst = function(elementType, value){
      var returnValue = value;
      if (value === undefined){
        if (dataBindSubstConfig.hasOwnProperty(elementType)){
          returnValue = dataBindSubstConfig[elementType];
        } else {
          returnValue = dataBindSubstConfig["default"];
        }
      }
      return returnValue;
    };

    setOnElement = function(element, attr, val){
      var valBefore = val;
      val = modelBinding.Configuration.getDataBindSubst(attr, val);
      switch(attr){
        case "html":
          element.html(val);
          break;
        case "text":
          element.text(val);
          break;
        case "enabled":
          element.attr("disabled", !val);
          break;
        case "displayed":
          element[val? "show" : "hide"]();
          break;
        case "hidden":
          element[val? "hide" : "show"]();
          break;
        default:
          element.attr(attr, val);
      }
    };

    splitBindingAttr = function(element)
    {
      var dataBindConfigList = [];
      var databindList = element.attr("data-bind").split(";");
      _.each(databindList, function(attrbind){
        var databind = $.trim(attrbind).split(" ");

        // make the default special case "text" if none specified
        if( databind.length == 1 ) databind.unshift("text");

        dataBindConfigList.push({
          elementAttr: databind[0],
          modelAttr: databind[1]
        });
      });
      return dataBindConfigList;
    };

    var methods = {};

    methods.bind = function(selector, view, model, config){
      var modelBinder = this;

      view.$(selector).each(function(index){
        var element = view.$(this);
        var databindList = splitBindingAttr(element);

        _.each(databindList, function(databind){
          var modelChange = function(model, val){
            setOnElement(element, databind.elementAttr, val);
          };

          modelBinder.registerModelBinding(model, databind.modelAttr, modelChange);

          // set default on data-bind element
          setOnElement(element, databind.elementAttr, model.get(databind.modelAttr));
        });

      });
    };

    return methods;
  })(Backbone, _, $);


  // ----------------------------
  // Binding Conventions
  // ----------------------------
  modelBinding.Conventions = {
    text: {selector: "input:text", handler: StandardBinding},
    textarea: {selector: "textarea", handler: StandardBinding},
    password: {selector: "input:password", handler: StandardBinding},
    radio: {selector: "input:radio", handler: RadioGroupBinding},
    checkbox: {selector: "input:checkbox", handler: CheckboxBinding},
    select: {selector: "select", handler: SelectBoxBinding},
    databind: { selector: "*[data-bind]", handler: DataBindBinding},
    // HTML5 input
    number: {selector: "input[type=number]", handler: StandardBinding},
    range: {selector: "input[type=range]", handler: StandardBinding},
    tel: {selector: "input[type=tel]", handler: StandardBinding},
    search: {selector: "input[type=search]", handler: StandardBinding},
    url: {selector: "input[type=url]", handler: StandardBinding},
    email: {selector: "input[type=email]", handler: StandardBinding}
  };

  return modelBinding;
})(Backbone, _, jQuery);
