/*
 * jquery.subscribe.1.1
 *
 * Implementation of publish/subcription framework for jQuery
 * Requires use of jQuery. Tested with jQuery 1.3 and above
 *
 *
 * Copyright (c) 2008 Eric Chijioke (obinna a-t g mail dot c o m)
 *
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 *  Release Notes:
 *
 *  version 1.1:
 *
 *  Fixed unexpected behavior which can occur when a script in a embedded page (page loaded in div,tab etc.) subscribes a handler for a topic using
 *  the jQuery subscribe ($.subscribe) or a no-id element but this subscribe plugin is not reloaded within that embedded page (for example, when
 *  script is included in containing page) . In this case, if the embedded page is reloaded without reloading the entire page (and plugin), the
 *  subscription could be made multiple times for the topic, which will call the handler multiple times each time the topic is published.
 *  Code has been added to prevent this when the subscription is made using the non-element subscribe ($.subscribe()), which assures that only one
 *  subscription is made for a topic for a given window/frame. To prevent this from happening for an element subscription ($elem.subscribe()), make
 *  sure that the element has an id attribute.
 */


(function($){

  _subscribe_topics = {};
  _subscribe_handlers = {};

  _subscribe_getDocumentWindow = function(document){

    return document.parentWindow || document.defaultView;
  };

  $.fn.extend({

    /**
     * Creates a new topic without any subscribers.
     * Not usually used explicitly
     */
    createTopic :  function(topic) {
      if(topic && !_subscribe_topics[topic]) {

        _subscribe_topics[topic] = {};
        _subscribe_topics[topic].objects = {};
        _subscribe_topics[topic].objects['__noId__'] = [];
      }

      return this;
    },

    /**
     * Destroy an existing topic and unsubscribe all subscribers
     */
    destroyTopic  :  function(topic) {

      if(topic && _subscribe_topics[topic]) {

        for(i in _subscribe_topics[topic].objects) {

          var object = _subscribe_topics[topic].objects[i];

          if($.isArray(object)) {   // handle '__noId__' elements

            if(object.length > 0) {

              for(j in object) {

                object[j].unbind(topic);
              }
            }

          } else {

            object.unbind(topic,data);
          }
        }
      }

      delete _subscribe_topics[topic];

      return this;
    },

    /**
     * Subscribes an object to particular topic with a handler.
     * When the topic is published, this handler will be executed.
     *
     * Parameters:
     *  -topic- is the string name of the topic
     *  -handler- is a handler function and is of the form function(event, data), in which the 'this' refers to the element itself.
     *        handler can be a function or can be a string referring to a function previously registered using the $.subscribeHandler() function
     *            Note: returning 'false' from the handler will prevent subsequent handlers from being executed on this element during
     *            this call.
     *  -data- (optional) is additional data that is passed to the event handler as event.data when the topic is published
     *
     * Note: Unexpected behavior can occur when a script in a embedded page (page loaded in div,tab etc.) subscribes a handler for a topic using
     *  the jQuery subscribe ($.subscribe) or a no-id element but this subscribe plugin is not reloaded within that embedded page (for example, when
     *  script is included in containing page) . In this case, if the embedded page is reloaded without reloading the entire page (and plugin), the
     *  subscription could be made multiple times for the topic, which will call the handler multiple times each time the topic is published.
     *  Code has been added to prevent this when the subscription is made using the non-element subscribe ($.subscribe()), which assures that only one
     *  subscription is made for a topic for a given window/frame. To prevent this from happening for an element subscription ($elem.subscribe()), make
     *  sure that the element has an id attribute.
     */
    subscribe :  function(topic, handler, data) {

      if(this[0] && topic && handler) {

        this.createTopic(topic);

        if(this.attr('id')) {

          _subscribe_topics[topic].objects[this.attr('id')] = this;

        } else {

          //do not subscribe the same window/frame document multiple times, this causes unexpected behavior of executing embedded scripts multiple times
          var noIdObjects = _subscribe_topics[topic].objects['__noId__'];

          if(this[0].nodeType == 9) { //if document is being bound (the case for non-element jQuery subscribing ($.subscribe)

            for ( var index in noIdObjects) {

              var noIdObject = noIdObjects[index];

              if(noIdObject[0].nodeType == 9 && _subscribe_getDocumentWindow(this[0]).frameElement == _subscribe_getDocumentWindow(noIdObject[0]).frameElement ) {

                return this;
              }
            }
          }

          var exists = false;
          for(var i = 0; i < noIdObjects.length; i++){
            if(noIdObjects[i] == this){
              exists = true;
              break;
            }
          }

          if(!exists) {

            _subscribe_topics[topic].objects['__noId__'].push(this);
          }
        }

        if(typeof(handler) == 'function') {

          this.bind(topic, data, handler);

        } else if(typeof(handler) == 'string' && typeof(_subscribe_handlers[handler]) == 'function') {

          this.bind(topic, data, _subscribe_handlers[handler]);
        }
      }

      return this;
    },

    /**
     * Remove a subscription of an element to a topic.
     * This will unbind stop all handlers from executing on this element when the topic
     * is published
     */
    unsubscribe :  function(topic) {

      if(topic) {

        if(_subscribe_topics[topic]) {

          if(this.attr('id')) {

            var object = _subscribe_topics[topic].objects[this.attr('id')];

            if(object) {

              delete _subscribe_topics[topic].objects[this.attr('id')];
            }

          } else {

            var noIdObjects = _subscribe_topics[topic].objects['__noId__'];

            for(var i = 0; i < noIdObjects.length; i++){

              if(noIdObjects[i] == this){

                subscribe_topics[topic].objects['__noId__'].splice(index,1);
                break;
              }
            }
          }
        }

        this.unbind(topic);
      }

      return this;
    },

    /**
     * Publishes a topic (triggers handlers on all topic subscribers)
     * This ends up calling any subscribed handlers which are functions of the form function (event, data)
     * where: event - is a standard jQuery event object
     *      data - is the data parameter that was passed to this publish() method
     *      event.data - is the data parameter passed to the subscribe() function when this published topic was subscribed to
     *      event.target  - is the dom element that subscribed to the event (or the document element if $.subscribe() was used)
     *
     * Parameters:
     *  -topic- is the string name of the topic
     *  -data- (optional) is additional data that is passed to the event handler 'data' parameter when the topic is published
     *        handler can be a function or can be a string referring to a function previously registered using the $.subscribeHandler() function
     *  -originalEvent- (optional) may be passed in a reference to an event which triggered this publishing. This will be passed as the
     *        'originalEvent' field of the triggered event which will allow for controlling the propagation of higher level events
     *        from within the topic handler. In other words, this allows one to cancel execution of all subsequent handlers on the originalEvent
     *            for this element by return 'false' from a handler that is subscribed to the topic published here. This can be especially useful
     *            in conjunction with publishOnEvent(), where a topic is published when an event executes (such as a click) and we want our
     *            handler logic prevent additional topics from being published (For example if our topic displays a 'delete confirm' dialog on click and
     *            the user cancels, we may want to prevent subsequent topics bound to the original click event from being published).
     */
    publish : function(topic, data, originalEvent) {

      if(topic) {

        this.createTopic(topic);

        //if an orginal event exists, need to modify the event object to prevent execution of all
        //other handlers if the result of the handler is false (which calls stopPropagation())

        var subscriberStopPropagation = function(){

          this.isImmediatePropagationStopped = function(){
            return true;
          };

          (new $.Event).stopPropagation();

          if(this.originalEvent) {

            this.originalEvent.isImmediatePropagationStopped = function(){
              return true;
            };

            this.originalEvent.stopPropagation = subscriberStopPropagation;
          }
        }

        var event = jQuery.Event(topic);
        $.extend(event,{originalEvent: originalEvent, stopPropagation: subscriberStopPropagation});

        for(i in _subscribe_topics[topic].objects) {

          var object = _subscribe_topics[topic].objects[i];

          if($.isArray(object)) {   // handle '__noId__' elements (if any)

            if(object.length > 0) {

              for(j in object) {

                object[j].trigger( event,data);
              }
            }

          } else {

            object.trigger( event,data);
          }
        }

      }

      return this;
    },

    /**
     * Binds an objects event handler to a publish call
     *
     * Upon the event triggering, this ends up calling any subscribed handlers which are functions of the form function (event, data)
     * where: event- is a standard jQuery event object
     *      event.data- is the data parameter passed to the subscribe() function when this published topic was subscribed to
     *      data- is the data parameter that was passed to this publishOnEvent() method
     * Parameters:
     *  -event- is the string name of the event upon which to publish the topic
     *  -topic- is the string name of the topic to publish when the event occurs
     *  -data- (optional) is additional data which will be passed in to the publish() method ant hen available as the second ('data')
     *          parameter to the topic handler
     */
    publishOnEvent : function(event, topic, data) {

      if(event && topic) {

        this.createTopic(topic);

        this.bind(event, data, function (e) {

          $(this).publish(topic, e.data, e);
        });
      }

      return this;
    }
  });

  /**
   * Make publish(), createTopic() and destroyTopic() callable without an element context
   * Often don't need a context to subscribe, publish, create or destroy a topic.
   * We will call from the document context
   */
  $.extend({

    /**
     * Subscribe an event handler to a topic without an element context
     *
     * Note: Caution about subscribing using same document to topic multiple time (maybe by loading subscribe script multiple times)
     *
     */
    subscribe :  function(topic, handler, data) {
      return $(window).subscribe(topic, handler, data);

    },

    /**
     * Unsubscribe an event handler for a topic without an element context
     *
     */
    unsubscribe :  function(topic, handler, data) {

      return $(window).unsubscribe(topic, handler, data);

    },

    /**
     * Register a handler function which can then be referenced by name when calling subscribe()
     */
    subscribeHandler: function(name, handler) {

      if(name && handler && typeof(handler) == "function") {

        _subscribe_handlers[name] = handler;
      }

      return $(window);
    },

    publish: function(topic, data) {

      return $(window).publish(topic,data);
    },

    createTopic: function(topic) {

      return $(window).createTopic(topic);
    },

    destroyTopic: function(topic) {

      return $(window).destroyTopic(topic);
    }

  });

})(jQuery);
