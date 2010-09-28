/**
* smartupdater - jQuery Plugin
*  
* Version - 2.0.0
*
* Copyright (c) 2010 Vadim Kiryukhin
* vkiryukhin@gmail.com
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*
* Based on the work done by Terry M. Schmidt and the jQuery ekko plugin.
*
* USAGE:
*
*	$("#myObject").smartupdater({
*			url : "demo.php",
*			minTimeout : 60000
*			}, function (data) {
*				//process data here;
*			}
*		);
*		
*	Public functions:
*		$("#myObject").smartupdaterStop();
*		$("#myObject").smartupdaterRestart();
*		$("#myObject").smartupdaterSetTimeout();
*
*	Public Attributes:
*		var smStatus = $("#myObject")[0].smartupdaterStatus.state; // "ON" | "OFF" | "undefined"
*		var smTimeout = $("#myObject")[0].smartupdaterStatus.timeout; // current timeout
*
**/

(function(jQuery) {
	jQuery.fn.smartupdater = function (options, callback) {

		return this.each(function () {
			var elem = this;

			elem.settings = jQuery.extend({
				url			: '',		// see jQuery.ajax for details
				type		: 'get', 	// see jQuery.ajax for details
				data		: '',   	// see jQuery.ajax for details
				dataType	: 'text', 	// see jQuery.ajax for details
						
				minTimeout	: 60000, // Starting value for the timeout in milliseconds; default 1 minute.
				maxTimeout	: ((1000 * 60) * 60), // Default 1 hour.
				multiplier	: 2,    //if set to 2, interval will double each time the response hasn't changed.
				maxFailedRequests : 10 // smartupdater stops after this number of consecutive ajax failures; 
				
			}, options);
				
			elem.smartupdaterStatus = {};
			elem.smartupdaterStatus.state = '';
			elem.smartupdaterStatus.timeout = 0;

			var es = elem.settings;
				
			es.prevContent = '';
			es.originalMinTimeout = es.minTimeout;
			es.failedRequests = 0;
			es.response = '';
				
			function start() {
				$.ajax({url: es.url, 
					type: es.type,
					data: es.data,
					dataType: es.dataType,
					success: function (data) {
						
						if(es.dataType == 'json') {
							es.response = JSON.stringify(data);
							if ( data.smartupdater) {
								es.originalMinTimeout = data.smartupdater;
							}
						} else {
							es.response = data;	
						}
						
						if (es.prevContent != es.response) {
							es.prevContent = es.response;
							es.minTimeout = es.originalMinTimeout;
							es.periodicalUpdater = setTimeout(start, es.minTimeout);
							elem.smartupdaterStatus.timeout = es.minTimeout;
							callback(data);
						} else if (es.multiplier > 1) {
							es.minTimeout = (es.minTimeout < es.maxTimeout) ? Math.round(es.minTimeout * es.multiplier) : es.maxTimeout;
							es.periodicalUpdater = setTimeout(start, es.minTimeout);
							elem.smartupdaterStatus.timeout = es.minTimeout;
						}
						
						es.failedRequests = 0;
						elem.smartupdaterStatus.state = 'ON';
					}, 
							
					error: function() { 
						if ( ++es.failedRequests < es.maxFailedRequests ) {
							es.periodicalUpdater = setTimeout(start, es.minTimeout);
							elem.smartupdaterStatus.timeout = es.minTimeout;
						} else {
							clearTimeout(es.periodicalUpdater);
							elem.smartupdaterStatus.state = 'OFF';
						}
					}
				})
			} 
				
			es.fnStart = start;
			start();
		});
	}; 
	
	jQuery.fn.smartupdaterStop = function () {
		return this.each(function () {
			var elem = this;
			clearTimeout(elem.settings.periodicalUpdater);
            elem.smartupdaterStatus.state = 'OFF';
		});
	}; 
        
    jQuery.fn.smartupdaterRestart = function () {        
		return this.each(function () {
			var elem = this;
			clearTimeout(elem.settings.periodicalUpdater);
            elem.settings.minTimeout = elem.settings.originalMinTimeout;
            elem.settings.fnStart();
		});
	}; 
	
	jQuery.fn.smartupdaterSetTimeout = function (period) {
		return this.each(function () {
			var elem = this;
			clearTimeout(elem.settings.periodicalUpdater);
			this.settings.originalMinTimeout = period;
            this.settings.fnStart();
		});
	}; 
	

})(jQuery);


/******************************************************
 *   http://www.JSON.org/json2.js
 *   2010-03-20
 *
 *  Public Domain.
 *
 *  NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
 *
 *   See http://www.JSON.org/js.html
 *********************************************************/
if(!this.JSON){this.JSON={}}(function(){function f(n){return n<10?"0"+n:n}if(typeof Date.prototype.toJSON!=="function"){Date.prototype.toJSON=function(key){return isFinite(this.valueOf())?this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z":null};String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(key){return this.valueOf()}}var cx=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,escapable=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,gap,indent,meta={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},rep;function quote(string){escapable.lastIndex=0;return escapable.test(string)?'"'+string.replace(escapable,function(a){var c=meta[a];return typeof c==="string"?c:"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+string+'"'}function str(key,holder){var i,k,v,length,mind=gap,partial,value=holder[key];if(value&&typeof value==="object"&&typeof value.toJSON==="function"){value=value.toJSON(key)}if(typeof rep==="function"){value=rep.call(holder,key,value)}switch(typeof value){case"string":return quote(value);case"number":return isFinite(value)?String(value):"null";case"boolean":case"null":return String(value);case"object":if(!value){return"null"}gap+=indent;partial=[];if(Object.prototype.toString.apply(value)==="[object Array]"){length=value.length;for(i=0;i<length;i+=1){partial[i]=str(i,value)||"null"}v=partial.length===0?"[]":gap?"[\n"+gap+partial.join(",\n"+gap)+"\n"+mind+"]":"["+partial.join(",")+"]";gap=mind;return v}if(rep&&typeof rep==="object"){length=rep.length;for(i=0;i<length;i+=1){k=rep[i];if(typeof k==="string"){v=str(k,value);if(v){partial.push(quote(k)+(gap?": ":":")+v)}}}}else{for(k in value){if(Object.hasOwnProperty.call(value,k)){v=str(k,value);if(v){partial.push(quote(k)+(gap?": ":":")+v)}}}}v=partial.length===0?"{}":gap?"{\n"+gap+partial.join(",\n"+gap)+"\n"+mind+"}":"{"+partial.join(",")+"}";gap=mind;return v}}if(typeof JSON.stringify!=="function"){JSON.stringify=function(value,replacer,space){var i;gap="";indent="";if(typeof space==="number"){for(i=0;i<space;i+=1){indent+=" "}}else{if(typeof space==="string"){indent=space}}rep=replacer;if(replacer&&typeof replacer!=="function"&&(typeof replacer!=="object"||typeof replacer.length!=="number")){throw new Error("JSON.stringify")}return str("",{"":value})}}if(typeof JSON.parse!=="function"){JSON.parse=function(text,reviver){var j;function walk(holder,key){var k,v,value=holder[key];if(value&&typeof value==="object"){for(k in value){if(Object.hasOwnProperty.call(value,k)){v=walk(value,k);if(v!==undefined){value[k]=v}else{delete value[k]}}}}return reviver.call(holder,key,value)}text=String(text);cx.lastIndex=0;if(cx.test(text)){text=text.replace(cx,function(a){return"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})}if(/^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){j=eval("("+text+")");return typeof reviver==="function"?walk({"":j},""):j}throw new SyntaxError("JSON.parse")}}}());