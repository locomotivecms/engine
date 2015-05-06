/*
 *  Project: PicEdit
 *  Description: Creates an image upload box with tools to edit the image on the front-end before uploading it to the server
 *  Author: Andy V.
 *  License: MIT
 */

// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
    "use strict";
    // undefined is used here as the undefined global variable in ECMAScript 3 is
    // mutable (ie. it can be changed by someone else). undefined isn't really being
    // passed in so we can ensure the value of it is truly undefined. In ES5, undefined
    // can no longer be modified.

    // window is passed through as local variable rather than global
    // as this (slightly) quickens the resolution process and can be more efficiently
    // minified (especially when both are regularly referenced in your plugin).

    // Create the default params object
    var pluginName = 'picEdit',
        defaults = {
			imageUpdated: function(img){},	// Image updated callback function
			formSubmitted: function(res){},	// After form was submitted callback function
			redirectUrl: false,				// Page url for redirect on form submit
			maxWidth: 400,					// Max width parameter
			maxHeight: 'auto',				// Max height parameter
			aspectRatio: true,				// Preserve aspect ratio
            defaultImage: false             // Default image to be used with the plugin
        };

    // The actual plugin constructor
    function Plugin( element, options ) {
        this.inputelement = element;
        this.element = element;

        // jQuery has an extend method which merges the contents of two or
        // more objects, storing the result in the first object. The first object
        // is generally empty as we don't want to alter the default options for
        // future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;
        // Reference to the loaded image
        this._image = false;
        // Reference to the filename of the loaded image
        this._filename = "";
        // Interface variables (data synced from the user interface)
        this._variables = {};

        /* Prepare the template */
        /*unhide_in_prod*/
         this._template(); 
        /*unhide_in_prod*/

        /*hide_in_prod*/ /* 
        this.init();
         */ /*hide_in_prod*/
    }

	Plugin.prototype = {
		init: function () {
				// Place initialization logic here
				// You already have access to the DOM element and
				// the options via the instance, e.g. this.element
				// and this.settings
				
				// Save instance of this for inline functions
				var _this = this;
                // Get type of element to be used (type="file" and type="picedit" are supported)
                var type = $(this.inputelement).prop("type");
                if(type == "file")
                    this._fileinput = $(this.inputelement);
                else {
                    // Create a reference to the file input box
                    $(this.inputelement).after('<input type="file" style="display:none" accept="image/*">');
				    this._fileinput = $(this.inputelement).next("input");
                }
                // Show regular file upload on old browsers
                if(!this.check_browser_capabilities()) {
                    if(type != "file") {
                        $(this.inputelement).prop("type", "file");
                        $(this._fileinput).remove();
                    }
                    $(this.inputelement).show();
                    $(this.element).remove();
                    return;
                }
				// Get reference to the main canvas element
				this._canvas = $(this.element).find(".picedit_canvas > canvas")[0];
				// Create and set the 2d context for the canvas
				this._ctx = this._canvas.getContext("2d");
				// Reference to video elemment holder element
				this._videobox = $(this.element).find(".picedit_video");
				// Reference to the painter element
				this._painter = $(this.element).find(".picedit_painter");
				this._painter_canvas = this._painter.children("canvas")[0];
				this._painter_ctx = this._painter_canvas.getContext("2d");
				this._painter_painting = false;
				// Save the reference to the messaging box
		 		this._messagebox = $(this.element).find(".picedit_message");
		 		this._messagetimeout = false;
				// Reference to the main/top nav buttons holder
				this._mainbuttons = $(this.element).find(".picedit_action_btns");
				// Size of the viewport to display image (a resized image will be displayed)
				 this._viewport = {
					"width": 0,
					"height": 0
				 };
				 // All variables responsible for cropping functionality
				 this._cropping = {
					 is_dragging: false,
					 is_resizing: false,
					 left: 0,
					 top: 0,
					 width: 0,
					 height: 0,
					 cropbox: $(this.element).find(".picedit_drag_resize"),
					 cropframe: $(this.element).find(".picedit_drag_resize_box")
				 };
				 function build_img_from_file(files) {
					if(!files && !files.length) return;
					var file = files[0];
					if(!_this._filename) {
						_this._filename = file.name;
					}
					var reader = new FileReader();
					reader.onload = function(e) { 
						_this._create_image_with_datasrc(e.target.result, false, file); 
					};
					reader.readAsDataURL(file);
				 }
				// Bind file drag-n-drop behavior
				$(this.element).find(".picedit_canvas_box").on("drop", function(event) {
					event.preventDefault();
					$(this).removeClass('dragging');
					var files = (event.dataTransfer || event.originalEvent.dataTransfer).files;
					build_img_from_file(files);
				}).on("dragover", function(event) {
					event.preventDefault();
					$(this).addClass('dragging');
				}).on("dragleave", function(event) {
					event.preventDefault();
					$(this).removeClass('dragging');
				});
				// Bind onchange event to the fileinput to pre-process the image selected
				$(this._fileinput).on("change", function() {
					build_img_from_file(this.files);
				});
				// If Firefox (doesn't support clipboard object), create DIV to catch pasted image
				if (!window.Clipboard) { // Firefox
					var pasteCatcher = $(document.createElement("div"));
					pasteCatcher.prop("contenteditable","true").css({
						"position" : "absolute", 
						"left" : -999,
						"width" : 0,
						"height" : 0,
						"overflow" : "hidden",
						"outline" : 0,
						"opacity" : 0
					});
					$(document.body).prepend(pasteCatcher);
				}
				// Bind onpaste event to capture images from the the clipboard
				$(document).on("paste", function(event) {
					var items = (event.clipboardData  || event.originalEvent.clipboardData).items;
					var blob;
					if(!items) {
						pasteCatcher.get(0).focus();
                        pasteCatcher.on('DOMSubtreeModified', function(){
                            var child = pasteCatcher.children().last().get(0);
							pasteCatcher.html("");
							if (child) {
								if (child.tagName === "IMG" && child.src.substr(0, 5) == 'data:') {
									_this._create_image_with_datasrc(child.src);
								}
                                else if (child.tagName === "IMG" && child.src.substr(0, 4) == 'http') {
									_this._create_image_with_datasrc(child.src, false, false, true);
								}
							}
                        });
					}
					else {
						for (var i = 0; i < items.length; i++) {
						  if (items[i].type.indexOf("image") === 0) {
							blob = items[i].getAsFile();
						  }
						}
						if(blob) {
						  var reader = new FileReader();
						  reader.onload = function(e) { _this._create_image_with_datasrc(e.target.result); };
						  reader.readAsDataURL(blob);
						}
					}
				});
				// Define formdata element
				this._theformdata = false;
				this._theform = $(this.inputelement).parents("form");
                // Bind form submit event
				if(this._theform.length) {
					this._theform.on("submit", function(){ return _this._formsubmit(); });
				}
				// Call helper functions
				this._bindControlButtons();
				this._bindInputVariables();
				this._bindSelectionDrag();
				// Set Default interface variable values
				this._variables.pen_color = "black";
				this._variables.pen_size = false;
				this._variables.prev_pos = false;
                // Load default image if one is set
                if(this.options.defaultImage) _this.set_default_image(this.options.defaultImage);
		},
        // Check Browser Capabilities (determine if the picedit should run, or leave the default file-input field)
        check_browser_capabilities: function () {
            if(!!window.CanvasRenderingContext2D == false) return false; //check canvas support
            if(!window.FileReader) return false; //check file reader support
            return true;    //otherwise return true
        },
        // Set the default Image
        set_default_image: function (path) {
            this._create_image_with_datasrc(path, false, false, true);
        },
		// Remove all notification copy and hide message box
		hide_messagebox: function () {
			var msgbox = this._messagebox;
			msgbox.removeClass("active no_close_button");
			setTimeout(function() {msgbox.children("div").html("")}, 200);
		},
		// Open a loading spinner message box or working... message box
		set_loading: function (message) {
			if(message && message == 1) {
				return this.set_messagebox("Working...", false, false);
			}
			else return this.set_messagebox("Please Wait...", false, false);
		},
		// Open message box alert with defined text autohide after number of milliseconds, display loading spinner
		set_messagebox: function (text, autohide, closebutton) {
			autohide = typeof autohide !== 'undefined' ? autohide : 3000;
			closebutton = typeof closebutton !== 'undefined' ? closebutton : true;
			var classes = "active";
			if(!closebutton) classes += " no_close_button";
			if(autohide) {
				clearTimeout(this._messagetimeout);
				var _this = this;
				this._messagetimeout = setTimeout(function(){ _this.hide_messagebox(); }, autohide);
			}
			return this._messagebox.addClass(classes).children("div").html(text);
		},
		// Toggle button and update variables
		toggle_button: function (elem) {
			if($(elem).hasClass("active")) {
				var value = false;
				$(elem).removeClass("active");
			}
			else {
				var value = true;
				$(elem).siblings().removeClass("active");
				$(elem).addClass("active");
			}
			var variable = $(elem).data("variable");
			if(variable) {
				var optional_value = $(elem).data("value");
				if(!optional_value) optional_value = $(elem).val();
				if(optional_value && value) value = optional_value;
				this._setVariable(variable, value);
			}
			if(this._variables.pen_color && this._variables.pen_size) this.pen_tool_open();
			else this.pen_tool_close();
		},
		// Perform image load when user clicks on image button
		load_image: function () {
			this._fileinput.click();
		},
		// Open pen tool and start drawing
		pen_tool_open: function () {
			if(!this._image) return this._hideAllNav(1);
			this.pen_tool_params_set();
			this._painter.addClass("active");
			this._hideAllNav();
		},
		// Set pen tool parameters
		pen_tool_params_set: function () {
			this._painter_canvas.width = 0;
			this._painter_canvas.width = this._canvas.width;
			this._painter_canvas.height = this._canvas.height;
			this._painter_ctx.lineJoin = "round";
			this._painter_ctx.lineCap = "round";
			this._painter_ctx.strokeStyle = this._variables.pen_color;
      		this._painter_ctx.lineWidth = this._variables.pen_size;
		},
		// Close pen tool
		pen_tool_close: function () {
			this._painter.removeClass("active");
		},
		// Rotate the image 90 degrees counter-clockwise
		rotate_ccw: function () {
			if(!this._image) return this._hideAllNav(1);
			var _this = this;
			//run task and show loading spinner, the task can take some time to run
			this.set_loading(1).delay(200).promise().done(function() {
				_this._doRotation(-90);
				_this._resizeViewport();
				//hide loading spinner
				_this.hide_messagebox();
			});
			//hide all opened navigation
			this._hideAllNav();
		},
		// Rotate the image 90 degrees clockwise
		rotate_cw: function () {
			if(!this._image) return this._hideAllNav(1);
			var _this = this;
			//run task and show loading spinner, the task can take some time to run
			this.set_loading(1).delay(200).promise().done(function() {
				_this._doRotation(90);
				_this._resizeViewport();
				//hide loading spinner
				_this.hide_messagebox();
			});
			//hide all opened navigation
			this._hideAllNav();
		},
		// Resize the image
		resize_image: function () {
			if(!this._image) return this._hideAllNav(1);
			var _this = this;
			this.set_loading(1).delay(200).promise().done(function() {
				//perform resize begin
				var canvas = document.createElement('canvas');
				var ctx = canvas.getContext("2d");
				canvas.width = _this._variables.resize_width;
				canvas.height = _this._variables.resize_height;
				ctx.drawImage(_this._image, 0, 0, canvas.width, canvas.height);
				_this._create_image_with_datasrc(canvas.toDataURL("image/png"), function() {
					_this.hide_messagebox();
				});
			});
			this._hideAllNav();
		},
		// Open video element and start capturing live video from camera to later make a photo
		camera_open: function() {
			var getUserMedia;
			var browserUserMedia = navigator.webkitGetUserMedia	||	// WebKit
									 navigator.mozGetUserMedia	||	// Mozilla FireFox
									 navigator.getUserMedia;			// 2013...
			if (!browserUserMedia) return this.set_messagebox("Sorry, your browser doesn't support WebRTC!");
			var _this = this;
			getUserMedia = browserUserMedia.bind(navigator);
			getUserMedia({
					audio: false,
					video: true
				},
				function(stream) {
					var videoElement = _this._videobox.find("video")[0];
					videoElement.src = URL.createObjectURL(stream);
					//resize viewport
					videoElement.onloadedmetadata = function() {
						if(videoElement.videoWidth && videoElement.videoHeight) {
							if(!_this._image) _this._image = {};
							_this._image.width = videoElement.videoWidth;
							_this._image.height = videoElement.videoHeight;
							_this._resizeViewport();
						}
					};
					_this._videobox.addClass("active");
				},
				function(err) {
					return _this.set_messagebox("No video source detected! Please allow camera access!");
				}
			);
		},
		camera_close: function() {
			this._videobox.removeClass("active");
		},
		take_photo: function() {
			var _this = this;
			var live = this._videobox.find("video")[0];
			var canvas = document.createElement('canvas');
			var ctx = canvas.getContext("2d");
			canvas.width = live.clientWidth;
			canvas.height = live.clientHeight;
			ctx.drawImage(live, 0, 0, canvas.width, canvas.height);
			this._create_image_with_datasrc(canvas.toDataURL("image/png"), function() {
				_this._videobox.removeClass("active");
			});
		},
		// Crop the image
		crop_image: function() {
			var crop = this._calculateCropWindow();
			var _this = this;
			this.set_loading(1).delay(200).promise().done(function() {
				var canvas = document.createElement('canvas');
				var ctx = canvas.getContext("2d");
				canvas.width = crop.width;
				canvas.height = crop.height;
				ctx.drawImage(_this._image, crop.left, crop.top, crop.width, crop.height, 0, 0, crop.width, crop.height);
				_this._create_image_with_datasrc(canvas.toDataURL("image/png"), function() {
					_this.hide_messagebox();
				});
			});
			this.crop_close();
		},
		crop_open: function () {
			if(!this._image) return this._hideAllNav(1);
			this._cropping.cropbox.addClass("active");
			this._hideAllNav();
		},
		crop_close: function () {
			this._cropping.cropbox.removeClass("active");
		},
		// Create and update image from datasrc
		_create_image_with_datasrc: function(datasrc, callback, file, dataurl) {
			var _this = this;
			var img = document.createElement("img");
            if(dataurl) img.setAttribute('crossOrigin', 'anonymous');
			if(file) img.file = file;
			img.src = datasrc;
			img.onload = function() {
				if(dataurl) {
                    var canvas = document.createElement('canvas');
                    var ctx = canvas.getContext('2d');
                    canvas.width = img.width;
                    canvas.height = img.height;
                    ctx.drawImage(img, 0, 0);
                    img.src = canvas.toDataURL('image/png');
                }
                _this._image = img;
				_this._resizeViewport();
				_this._paintCanvas();
				_this.options.imageUpdated(_this._image);
				_this._mainbuttons.removeClass("active");
				if(callback && typeof(callback) == "function") callback();
			};
		},
		// Functions to controll cropping functionality (drag & resize cropping box)
		_bindSelectionDrag: function() {
			var _this = this;
			var eventbox = this._cropping.cropframe;
			var painter = this._painter;
			var resizer = this._cropping.cropbox.find(".picedit_drag_resize_box_corner_wrap");
			$(window).on("mousedown touchstart", function(e) {
				var evtpos = (e.clientX) ? e : e.originalEvent.touches[0];
				_this._cropping.x = evtpos.clientX;
   				_this._cropping.y = evtpos.clientY;
				_this._cropping.w = eventbox[0].clientWidth;
   				_this._cropping.h = eventbox[0].clientHeight;
				eventbox.on("mousemove touchmove", function(event) {
					event.stopPropagation();
        			event.preventDefault();
					_this._cropping.is_dragging = true;
					if(!_this._cropping.is_resizing) _this._selection_drag_movement(event);
				});
				resizer.on("mousemove touchmove", function(event) {
					event.stopPropagation();
        			event.preventDefault();
					_this._cropping.is_resizing = true;
					_this._selection_resize_movement(event);
				});
				painter.on("mousemove touchmove", function(event) {
					event.stopPropagation();
        			event.preventDefault();
					_this._painter_painting = true;
					_this._painter_movement(event);
				});
			}).on("mouseup touchend", function() {
				if (_this._painter_painting) {
					_this._painter_merge_drawing();
				}
				_this._cropping.is_dragging = false;
				_this._cropping.is_resizing = false;
				_this._painter_painting = false;
				_this._variables.prev_pos = false;
				eventbox.off("mousemove touchmove");
				resizer.off("mousemove touchmove");
				painter.off("mousemove touchmove");
			});
		},
		_selection_resize_movement: function(e) {
			var cropframe = this._cropping.cropframe[0];
			var evtpos = (e.clientX) ? e : e.originalEvent.touches[0];
			cropframe.style.width = (this._cropping.w + evtpos.clientX - this._cropping.x) + 'px';
   			cropframe.style.height = (this._cropping.h + evtpos.clientY - this._cropping.y) + 'px';
		},
		_selection_drag_movement: function(e) {
			var cropframe = this._cropping.cropframe[0];
			var evtpos = (e.pageX) ? e : e.originalEvent.touches[0];
			this._cropping.cropframe.offset({
				top: evtpos.pageY - parseInt(cropframe.clientHeight / 2, 10),
				left: evtpos.pageX - parseInt(cropframe.clientWidth / 2, 10)
			});
		},
		_painter_movement: function(e) {
			var pos = {};
			var target = e.target || e.srcElement,
			rect = target.getBoundingClientRect(),
			evtpos = (e.clientX) ? e : e.originalEvent.touches[0];
			pos.x = evtpos.clientX - rect.left;
			pos.y = evtpos.clientY - rect.top;
			if(!this._variables.prev_pos) {
				return this._variables.prev_pos = pos;
			}
			this._painter_ctx.beginPath();
    		this._painter_ctx.moveTo(this._variables.prev_pos.x, this._variables.prev_pos.y);
    		this._painter_ctx.lineTo(pos.x, pos.y);
    		this._painter_ctx.stroke();
			this._variables.prev_pos = pos;
		},
		_painter_merge_drawing: function() {
			var canvas = document.createElement('canvas');
			var ctx = canvas.getContext("2d");
			var _this = this;
			canvas.width = this._image.width;
			canvas.height = this._image.height;
			ctx.drawImage(this._image, 0, 0, canvas.width, canvas.height);
			ctx.drawImage(this._painter_canvas, 0, 0, canvas.width, canvas.height);
			if(canvas.width > 1280 && canvas.height > 800) {
				this.set_loading().delay(200).promise().done(function() {
					_this._create_image_with_datasrc(canvas.toDataURL("image/png"), function() {
						_this.pen_tool_params_set();
						_this.hide_messagebox();
					});
				});
			}
			else {
				this._create_image_with_datasrc(canvas.toDataURL("image/png"), function() {
					_this.pen_tool_params_set();
				});
			}
		},
		// Hide all opened navigation and active buttons (clear plugin's box elements)
		_hideAllNav: function (message) {
			if(message && message == 1) {
				this.set_messagebox("Open an image or use your camera to make a photo!");
			}
			$(this.element).find(".picedit_nav_box").removeClass("active").find(".picedit_element").removeClass("active");
		},
		// Paint image on canvas
		_paintCanvas: function () {
			this._canvas.width = this._viewport.width;
    		this._canvas.height = this._viewport.height;
			this._ctx.drawImage(this._image, 0, 0, this._viewport.width, this._viewport.height);
			$(this.element).find(".picedit_canvas").css("display", "block");
		},
		// Helper function to translate crop window size to the actual crop size
		_calculateCropWindow: function (){
			var view = this._viewport;		//viewport sizes
			var cropframe = this._cropping.cropframe[0];
			var real = {						//image real sizes
				"width": this._image.width,
				"height": this._image.height
			};
			var crop = {						//crop area sizes and position
				"width": cropframe.clientWidth,
				"height": cropframe.clientHeight,
				"top": (cropframe.offsetTop > 0) ? cropframe.offsetTop : 0.1,
				"left": (cropframe.offsetLeft > 0) ? cropframe.offsetLeft : 0.1
			};
			if((crop.width + crop.left) > view.width) crop.width = view.width - crop.left;
			if((crop.height + crop.top) > view.height) crop.height = view.height - crop.top;
			//calculate width and height for the full image size
			var width_percent = crop.width / view.width;
			var height_percent = crop.height / view.height;
			var area = {
				"width": parseInt(real.width * width_percent, 10),
				"height": parseInt(real.height * height_percent, 10)
			};
			//calculate actual top and left crop position
			var top_percent = crop.top / view.height;
			var left_percent = crop.left / view.width;
			area.top = parseInt(real.height * top_percent, 10);
			area.left = parseInt(real.width * left_percent, 10);
			return area;
		},
		// Helper function to perform canvas rotation
		_doRotation: function (degrees){
			var rads=degrees*Math.PI/180;
			//if rotation is 90 or 180 degrees try to adjust proportions
			var newWidth, newHeight;
			var c = Math.cos(rads);
			var s = Math.sin(rads);
			if (s < 0) { s = -s; }
			if (c < 0) { c = -c; }
			newWidth = this._image.height * s + this._image.width * c;
			newHeight = this._image.height * c + this._image.width * s;
			//create temporary canvas and context
			var canvas = document.createElement('canvas');
			var ctx = canvas.getContext("2d");
			canvas.width = parseInt(newWidth, 10);
			canvas.height = parseInt(newHeight, 10);
			// calculate the centerpoint of the canvas
			var cx=canvas.width/2;
			var cy=canvas.height/2;
			// draw the rect in the center of the newly sized canvas
			ctx.clearRect(0, 0, canvas.width, canvas.height);
			ctx.translate(cx, cy);
			ctx.rotate(rads);
			ctx.drawImage(this._image, -this._image.width / 2, -this._image.height / 2);
			this._image.src = canvas.toDataURL("image/png");
			this._paintCanvas();
			this.options.imageUpdated(this._image);
		},
		// Resize the viewport (should be done on every image change)
		_resizeViewport: function () {
			//get image reference
			var img = this._image;
			//set correct viewport width
			var viewport = {
				"width": img.width,
				"height": img.height
			};
			if(this.options.maxWidth != 'auto' && img.width > this.options.maxWidth) viewport.width = this.options.maxWidth;
			if(this.options.maxHeight != 'auto' && img.height > this.options.maxHeight) viewport.height = this.options.maxHeight;
			//calculate appropriate viewport size and resize the canvas
			if(this.options.aspectRatio) {
				var resizeWidth = img.width;
    			var resizeHeight = img.height;
				var aspect = resizeWidth / resizeHeight;
				if (resizeWidth > viewport.width) {
				  viewport.width = parseInt(viewport.width, 10);
				  viewport.height = parseInt(viewport.width / aspect, 10);
				}
				if (resizeHeight > viewport.height) {
				  aspect = resizeWidth / resizeHeight;
				  viewport.height = parseInt(viewport.height, 10);
				  viewport.width = parseInt(viewport.height * aspect, 10);
				}
			}
			//set the viewport size (resize the canvas)
			$(this.element).css({
				"width": viewport.width,
				"height": viewport.height
			});
			//set the global viewport
			this._viewport = viewport;
			//update interface data (original image width and height)
			this._setVariable("resize_width", img.width);
			this._setVariable("resize_height", img.height);
		},
		// Bind click and action callbacks to all buttons with class: ".picedit_control"
		_bindControlButtons: function() {
			var _this = this;
			$(this.element).find(".picedit_control").bind( "click", function() {
				// check to see if the element has a data-action attached to it
				var action = $(this).data("action");
				if(action) {
					_this[action](this);
				}
				// handle click actions on top nav buttons
				else if($(this).hasClass("picedit_action")) {
					$(this).parent(".picedit_element").toggleClass("active").siblings(".picedit_element").removeClass("active");
					if($(this).parent(".picedit_element").hasClass("active")) 
						$(this).closest(".picedit_nav_box").addClass("active");
					else 
						$(this).closest(".picedit_nav_box").removeClass("active");
				}
			});
		},
		// Bind input elements to the application variables
		_bindInputVariables: function() {
			var _this = this;
			$(this.element).find(".picedit_input").bind( "change keypress paste input", function() {
				// check to see if the element has a data-action attached to it
				var variable = $(this).data("variable");
				if(variable) {
					var value = $(this).val();
					_this._variables[variable] = value;
				}
				if((variable == "resize_width" || variable == "resize_height") && _this._variables.resize_proportions) {
					var aspect = _this._image.width / _this._image.height;
					if(variable == "resize_width") _this._setVariable("resize_height", parseInt(value / aspect, 10));
					else _this._setVariable("resize_width", parseInt(value * aspect, 10));
				}
			});
		},
		// Set an interface variable and update the corresponding dom element (M-V binding)
		_setVariable: function(variable, value) {
			this._variables[variable] = value;
			$(this.element).find('[data-variable="' + variable + '"]').val(value);
		},
		// form submitted
		_formsubmit: function() {
			if(!window.FormData) this.set_messagebox("Sorry, the FormData API is not supported!");
			else {
				var _this = this;
				this.set_loading().delay(200).promise().done(function() {
					_this._theformdata = new FormData(_this._theform[0]);
					if(_this._image) {
						var inputname = $(_this.inputelement).prop("name") || "file";
						var inputblob = _this._dataURItoBlob(_this._image.src);
						if(!_this._filename) _this._filename = inputblob.type.replace("/", ".");
						else _this._filename = _this._filename.match(/^[^\.]*/) + "." + inputblob.type.match(/[^\/]*$/);
						_this._theformdata.append(inputname, inputblob, _this._filename);
					}
					//send request
					var request = new XMLHttpRequest();
                    request.onprogress = function(e) {
                        if(e.lengthComputable) var total = e.total;
                        else var total = Math.ceil(inputblob.size * 1.3);
                        var progress = Math.ceil(((e.loaded)/total)*100);
                        if (progress > 100) progress = 100;
                        _this.set_messagebox("Please Wait... Uploading... " + progress + "% Uploaded.", false, false);
                    };
					request.open(_this._theform.prop("method"), _this._theform.prop("action"), true);
					request.onload = function(e) {
						if(this.status != 200) {
                            _this.set_messagebox("Server did not accept data!");
                        }
                        else {
                            if(_this.options.redirectUrl === true) window.location.reload();
						    else if(_this.options.redirectUrl) window.location = _this.options.redirectUrl;
						    else _this.set_messagebox("Data successfully submitted!");
                        }
						_this.options.formSubmitted(this);
					};
					request.send(_this._theformdata);
				});
			}
			return false;
		},
		_dataURItoBlob: function(dataURI) {
			if(!dataURI) return null;
			else var mime = dataURI.match(/^data\:(.+?)\;/);
			var byteString = atob(dataURI.split(',')[1]);
			var ab = new ArrayBuffer(byteString.length);
			var ia = new Uint8Array(ab);
			for (var i = 0; i < byteString.length; i++) {
				ia[i] = byteString.charCodeAt(i);
			}
			return new Blob([ab], {type: mime[1]});
		},
		// Prepare the template here
		_template: function() {
			var template = '<div class="picedit_box"> <div class="picedit_message"> <span class="picedit_control ico-picedit-close" data-action="hide_messagebox"></span> <div><\/div><\/div><div class="picedit_nav_box picedit_gray_gradient"> <div class="picedit_pos_elements"><\/div><div class="picedit_nav_elements"><div class="picedit_element"> <span class="picedit_control picedit_action ico-picedit-pencil" title="Pen Tool"></span> <div class="picedit_control_menu"> <div class="picedit_control_menu_container picedit_tooltip picedit_elm_3"> <label class="picedit_colors"> <span title="Black" class="picedit_control picedit_action picedit_black active" data-action="toggle_button" data-variable="pen_color" data-value="black"></span> <span title="Red" class="picedit_control picedit_action picedit_red" data-action="toggle_button" data-variable="pen_color" data-value="red"></span> <span title="Green" class="picedit_control picedit_action picedit_green" data-action="toggle_button" data-variable="pen_color" data-value="green"></span> </label> <label> <span class="picedit_separator"></span> </label> <label class="picedit_sizes"> <span title="Large" class="picedit_control picedit_action picedit_large" data-action="toggle_button" data-variable="pen_size" data-value="16"></span> <span title="Medium" class="picedit_control picedit_action picedit_medium" data-action="toggle_button" data-variable="pen_size" data-value="8"></span> <span title="Small" class="picedit_control picedit_action picedit_small" data-action="toggle_button" data-variable="pen_size" data-value="3"></span> </label> <\/div><\/div><\/div><div class="picedit_element"><span class="picedit_control picedit_action ico-picedit-insertpicture" title="Crop" data-action="crop_open"></span> <\/div><div class="picedit_element"> <span class="picedit_control picedit_action ico-picedit-redo" title="Rotate"></span> <div class="picedit_control_menu"> <div class="picedit_control_menu_container picedit_tooltip picedit_elm_1"> <label> <span>90° CW</span> <span class="picedit_control picedit_action ico-picedit-redo" data-action="rotate_cw"></span> </label> <label> <span>90° CCW</span> <span class="picedit_control picedit_action ico-picedit-undo" data-action="rotate_ccw"></span> </label> <\/div><\/div><\/div><div class="picedit_element"> <span class="picedit_control picedit_action ico-picedit-arrow-maximise" title="Resize"></span> <div class="picedit_control_menu"> <div class="picedit_control_menu_container picedit_tooltip picedit_elm_2"> <label><span class="picedit_control picedit_action ico-picedit-checkmark" data-action="resize_image"></span><span class="picedit_control picedit_action ico-picedit-close" data-action=""></span> </label> <label> <span>Width (px)</span> <input type="text" class="picedit_input" data-variable="resize_width" value="0"> </label> <label class="picedit_nomargin"> <span class="picedit_control ico-picedit-link" data-action="toggle_button" data-variable="resize_proportions"></span> </label> <label> <span>Height (px)</span> <input type="text" class="picedit_input" data-variable="resize_height" value="0"> </label> <\/div><\/div><\/div></div></div><div class="picedit_canvas_box"><div class="picedit_painter"><canvas></canvas></div><div class="picedit_canvas"><canvas></canvas></div><div class="picedit_action_btns active"> <div class="picedit_control ico-picedit-picture" data-action="load_image"><\/div><div class="picedit_control ico-picedit-camera" data-action="camera_open"><\/div><div class="center">or copy/paste image here</div></div></div><div class="picedit_video"> <video autoplay></video><div class="picedit_video_controls"><span class="picedit_control picedit_action ico-picedit-checkmark" data-action="take_photo"></span><span class="picedit_control picedit_action ico-picedit-close" data-action="camera_close"></span><\/div><\/div><div class="picedit_drag_resize"> <div class="picedit_drag_resize_canvas"></div><div class="picedit_drag_resize_box"><div class="picedit_drag_resize_box_corner_wrap"> <div class="picedit_drag_resize_box_corner"></div></div><div class="picedit_drag_resize_box_elements"><span class="picedit_control picedit_action ico-picedit-checkmark" data-action="crop_image"></span><span class="picedit_control picedit_action ico-picedit-close" data-action="crop_close"></span><\/div><\/div></div></div>';
			var _this = this;
			$(this.inputelement).hide().after(template).each(function() {
				_this.element = $(_this.inputelement).next(".picedit_box");
				_this.init();
			});
		}
	};

    // You don't need to change something below:
    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations and allowing any
    // public function (ie. a function whose name doesn't start
    // with an underscore) to be called via the jQuery plugin,
    // e.g. $(element).defaultPluginName('functionName', arg1, arg2)
    $.fn[pluginName] = function ( options ) {
        var args = arguments;

        // Is the first parameter an object (options), or was omitted,
        // instantiate a new instance of the plugin.
        if (options === undefined || typeof options === 'object') {
            return this.each(function () {

                // Only allow the plugin to be instantiated once,
                // so we check that the element has no plugin instantiation yet
                if (!$.data(this, 'plugin_' + pluginName)) {

                    // if it has no instance, create a new one,
                    // pass options to our plugin constructor,
                    // and store the plugin instance
                    // in the elements jQuery data object.
                    $.data(this, 'plugin_' + pluginName, new Plugin( this, options ));
                }
            });

        // If the first parameter is a string and it doesn't start
        // with an underscore or "contains" the `init`-function,
        // treat this as a call to a public method.
        } else if (typeof options === 'string' && options[0] !== '_' && options !== 'init') {

            // Cache the method call
            // to make it possible
            // to return a value
            var returns;

            this.each(function () {
                var instance = $.data(this, 'plugin_' + pluginName);

                // Tests that there's already a plugin-instance
                // and checks that the requested public method exists
                if (instance instanceof Plugin && typeof instance[options] === 'function') {

                    // Call the method of our plugin instance,
                    // and pass it the supplied arguments.
                    returns = instance[options].apply( instance, Array.prototype.slice.call( args, 1 ) );
                }

                // Allow instances to be destroyed via the 'destroy' method
                if (options === 'destroy') {
                  $.data(this, 'plugin_' + pluginName, null);
                }
            });

            // If the earlier cached method
            // gives a value back return the value,
            // otherwise return this to preserve chainability.
            return returns !== undefined ? returns : this;
        }
    };

}(jQuery, window, document));