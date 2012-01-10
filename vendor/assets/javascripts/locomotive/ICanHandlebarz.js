/*!
ICanHandlebarz.js version 0.1 -- by @ehntoo, based on ICanHaz.js by @HenrikJoreteg
More info at: http://github.com/ehntoo/ICanHandlebarz.js
*/
(function ($) {
/*!
  ICanHandlebarz.js -- by @ehntoo, based on ICanHaz.js by @HenrikJoreteg
*/
/*global jQuery  */
function ICanHandlebarz() {
    var self = this;
    self.VERSION = "0.1";
    self.templates = {};

    // public function for adding templates
    // We're enforcing uniqueness to avoid accidental template overwrites.
    // If you want a different template, it should have a different name.
    self.addTemplate = function (name, templateString) {
        if (self[name]) throw "Invalid name: " + name + ".";
        if (self.templates[name]) throw "Template \" + name + \" exists";

        self.templates[name] = Handlebars.compile(templateString);
        self[name] = function (data, title, raw) {
            data = data || {};
            var result = self.templates[name](data);
            return raw? result: $(result);
        };
    };

    // public function for adding partials
    self.addPartial = function (name, templateString) {
        if (Handlebars.partials[name]) throw "Partial \" + name + \" exists";
        Handlebars.registerPartial(name, templateString);
    };

    self.addHelper = function (name, func, args) {
        if (Handlebars.helpers[name]) throw "Helper \" + name + \" exists";
        if (typeof func === 'function') {
            Handlebars.registerHelper(name, func);
        } else {
            Handlebars.registerHelper(name, new Function(args, func));
        }
    }

    // grabs templates from the DOM and caches them.
    // Loop through and add templates.
    // Whitespace at beginning and end of all templates inside <script> tags will
    // be trimmed. If you want whitespace around a partial, add it in the parent,
    // not the partial. Or do it explicitly using <br/> or &nbsp;
    self.grabTemplates = function () {
        $('script[type="text/html"]').each(function (a, b) {
            var script = $((typeof a === 'number') ? b : a), // Zepto doesn't bind this
                text = (''.trim) ? script.html().trim() : $.trim(script.html());

            if (script.hasClass('partial')) {
                self.addPartial(script.attr('id'), text);
            } else if (script.hasClass('helper')) {
                // Does this even work?
                self.addHelper(script.attr('id'), text, script.attr('data-args'));
            } else {
                self.addTemplate(script.attr('id'), text);
            }
            script.remove();
        });
    };

    // clears all retrieval functions and empties caches
    self.clearAll = function () {
        for (var key in self.templates) {
            delete self[key];
        }
        self.templates = {};
        Handlebars.partials = {};
    };

    self.refresh = function () {
        self.clearAll();
        self.grabTemplates();
    };
}

window.ich = new ICanHandlebarz();

// init itself on document ready
$(function () {
    ich.grabTemplates();
});
})(window.jQuery || window.Zepto);