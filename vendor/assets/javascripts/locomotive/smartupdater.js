/**
* smartupdater - jQuery Plugin
*
* Version - 4.0.beta
* Copyright (c) 2010 - 2011 Vadim Kiryukhin
* vkiryukhin @ gmail.com
*
* http://www.eslinstructor.net/smartupdater/
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*
* USAGE:
*
* $("#myObject").smartupdater({
*     url : "foo.php"
*     }, function (data) {
*       //process data here;
*     }
*   );
*
* Public functions:
*   $("#myObject").smartupdater("stop")
*   $("#myObject").smartupdater("restart");
*   $("#myObject").smartupdater("setTimeout",timeout);
*   $("#myObject").smartupdater("alterUrl"[,"foo.php"[,data]]);
*   $("#myObject").smartupdater("alterCallback"[, foo]);
*
* Public Attributes:
*   var status  = $("#myObject").smartupdater("getState");
*   var timeout = $("#myObject").smartupdater("getTimeout");
*
**/

(function($) {


    var methods = {

      init : function( options, callback) {
        return this.each(function () {
          var elem = this,
          es = {};

          elem.settings = jQuery.extend(true,{
            url         : '',   // see jQuery.ajax for details
            type        : 'get',  // see jQuery.ajax for details
            data        : '',     // see jQuery.ajax for details
            dataType      : 'text',   // see jQuery.ajax for details

            minTimeout      : 60000,  // 1 minute
            maxFailedRequests   : 10,     // max. number of consecutive ajax failures
            maxFailedRequestsCb : false,  // falure callback function
            httpCache       : false,  // http cache
            rCallback     : false,  // remote callback functions
            selfStart     : true,   // start automatically after initializing
            smartStop     : { active:     false,  //disabled by default
                        monitorTimeout: 2500,   // 2.5 seconds
                        minHeight:    1,      // 1px
                        minWidth:   1     // 1px
                        }

          }, options);

          elem.smartupdaterStatus = {state:'',timeout:0};

          es = elem.settings;

          es.prevContent    = '';
          es.failedRequests = 0;
          es.etag       = '0';
          es.lastModified   = '0';
          es.callback     = callback;
          es.origReq = {url:es.url,data:es.data,callback:callback};
          es.stopFlag = false;


          function start() {

          /* check if element has been deleted and clean it up  */
            if(!$(elem).parents('body').length) {
                clearInterval(elem.smartupdaterStatus.smartStop);
                clearTimeout(elem.settings.h);
                elem = {};
                return;
            }

            $.ajax({
              url   : es.url,
              type  : es.type,
              data  : es.data,
              dataType: es.dataType,
              cache : false, // MUST be set to false to prevent IE caching issue.

              success: function (data, statusText, xhr) {

                var dataNotModified = false,
                  rCallback = false,
                  xSmart = jQuery.parseJSON(xhr.getResponseHeader("X-Smartupdater")),
                  xhrEtag, xhrLM;

                if(xSmart) { // remote control

                  /* remote timeout */
                  es.minTimeout = xSmart.timeout ? xSmart.timeout : es.minTimeout;

                  /* remote callback */
                  rCallback = xSmart.callback ? xSmart.callback : false;
                }

                if(es.httpCache) { // http cache process here

                  xhrEtag = xhr.getResponseHeader("ETag");
                  xhrLM = xhr.getResponseHeader("Last-Modified");

                  dataNotModified = (es.etag ==  xhrEtag || es.lastModified == xhrLM) ? true : false;
                  es.etag     =  xhrEtag ? xhrEtag : es.etag;
                  es.lastModified =  xhrLM   ? xhrLM   : es.lastModified;
                }

                if (  dataNotModified ||
                    es.prevContent == xhr.responseText ||
                    xhr.status == 304 ) { // data is not changed

                    if(!es.stopFlag) {
                      clearTimeout(es.h);
                      es.h = setTimeout(start, es.minTimeout);
                    }

                } else { // data is changed

                /* cache response data */
                  es.prevContent = xhr.responseText;

                /* reset timeout */
                  if(!es.stopFlag) {
                    clearTimeout(es.h);
                    es.h = setTimeout(start, es.minTimeout);
                  }

                /* run callback function */
                  if(es.rCallback && rCallback && es.rCallback.search(rCallback) != -1) {
                    window[rCallback](data);
                  } else  {
                    es.callback(data);
                  }
                }

                elem.smartupdaterStatus.timeout = es.minTimeout;
                es.failedRequests = 0;
              },

              error: function(xhr, textStatus, errorThrown) {
                if ( ++es.failedRequests < es.maxFailedRequests ) {

                /* increment falure counter and reset timeout */
                  if(!es.stopFlag) {
                    clearTimeout(es.h);
                    es.h = setTimeout(start, es.minTimeout);
                    elem.smartupdaterStatus.timeout = es.minTimeout;
                  }

                } else {

                /* stop smartupdater */
                  clearTimeout(es.h);
                  elem.smartupdaterStatus.state = 'OFF';
                  if( typeof(es.maxFailedRequestsCb)==='function') {
                    es.maxFailedRequestsCb(xhr, textStatus, errorThrown);
                  }
                }
              },

              beforeSend: function(xhr, settings) {

                if(es.httpCache) {

                /* set http cache-related headers */
                  xhr.setRequestHeader("If-None-Match", es.etag );
                  xhr.setRequestHeader("If-Modified-Since", es.lastModified );
                }

              /* Feedback: Smartupdater sends it's current timeout to server */
                xhr.setRequestHeader("X-Smartupdater", '{"timeout":"'+elem.smartupdaterStatus.timeout+'"}');
              }
            });

            elem.smartupdaterStatus.state = 'ON';
          }

          es.fnStart = start;

          if(es.selfStart) {
            start();
          }

          if(es.smartStop.active) {

            elem.smartupdaterStatus.smartStop = setInterval(function(){

              // check if object has been deleted
              if(!$(elem).parents('body').length) {
                clearInterval(elem.smartupdaterStatus.smartStop);
                clearTimeout(elem.settings.h);
                elem = {};
                return;
              }

              var $elem = $(elem);
              var width =  $elem.width(),
                height = $elem.height(),
                hidden = $elem.is(":hidden");

              //element has been expanded, so smartupdater should be re-started.
              if(!hidden && height > es.smartStop.minHeight && width > es.smartStop.minWidth
                 && elem.smartupdaterStatus.state=="OFF") {
                $elem.smartupdater("restart");
              } else
              //element has been minimized, so smartupdater should be stopped.
              if( (hidden || height <= es.smartStop.minHeight || width <= es.smartStop.minWidth)
                  && elem.smartupdaterStatus.state=="ON") {
                $elem.smartupdater("stop");

              }

            },es.smartStop.monitorTimeout);
          }

        });

      },// init()

      stop : function () {
        return this.each(function () {
          this.settings.stopFlag = true;
          clearTimeout(this.settings.h);
          this.smartupdaterStatus.state = 'OFF';
        });
      },

      restart : function () {
        return this.each(function () {
          this.settings.stopFlag = false;
          clearTimeout(this.settings.h);
          this.settings.failedRequests = 0;
          this.settings.etag = "0";
          this.settings.lastModified = "0";
          this.settings.fnStart();
        })
      },

      setTimeout : function (period) {
        return this.each(function () {
          clearTimeout(this.settings.h);
          this.settings.minTimeout = period;
          this.settings.fnStart();
        });
      },

      alterCallback : function (callback) {
        return this.each(function () {
          this.settings.callback  = callback  ? callback  : this.settings.origReq.callback;
        });
      },

      alterUrl : function (url,data) {
        return this.each(function () {
          this.settings.url   = url   ? url : this.settings.origReq.url;
          this.settings.data  = data  ? data : this.settings.origReq.data;
        });
      },

      getTimeout : function () {
        return this[0].smartupdaterStatus.timeout;
      },

      getState : function () {
        return this[0].smartupdaterStatus.state;
      }

    }; //methods

  jQuery.fn.smartupdater = function (options, callback) {

    if ( methods[options] ) {
      return methods[ options ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof options === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  options + ' does not exist on jQuery.tooltip' );
    }
  };


})(jQuery);
