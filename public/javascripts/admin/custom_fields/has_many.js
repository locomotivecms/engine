$(document).ready(function() {
  // add/remove/sort items in a has_many relationship
  $('.has-many-selector').hasManySelector();
});

(function($){
  $.fn.hasManySelector = function(options) {

    var populateSelect = function(context) {
      context.select.find('option').remove();

      for (var i = 0; i < context.data.collection.length; i++) {
        var obj = context.data.collection[i];
        if ($.inArray(obj[1], context.data.taken_ids) == -1)
          context.select.append(new Option(obj[0], obj[1], true, true));
      }

      if (context.select.find('option').size() == 0)
        context.list.find('li.template').hide();
      else
        context.list.find('li.template').show();
    }

    var addId = function(context, id) {
      context.data.taken_ids.push(id);

      populateSelect(context);

      if (context.data.taken_ids.length > 0) {
        context.empty.hide();
        context.list.next('input[type=hidden]').remove();
      }

      if (context.data.taken_ids.length ==  context.data.collection.length)
        context.sep.hide();
    }

    var removeId = function(context, id) {
      context.data.taken_ids = jQuery.grep(context.data.taken_ids, function(value) {
        return value != id;
      });

      populateSelect(context);

      if (context.data.taken_ids.length == 0) {
        context.empty.show();
        context.list.after('<input type="hidden" name="' + context.baseInputName + '" value="" />');
      }

      context.sep.show();
    }

    var registerElementEvents = function(context, data, domElement) {
      // remove
      domElement.find('a.remove').click(function(e) {
        domElement.remove();

        removeId(context, data.id);

        context.list.sortable('refresh');

        e.preventDefault(); e.stopPropagation();
      });
    }

    var registerElementTemplateEvents = function(context, domElement) {
      // bind the "Add field" button
      domElement.find('button').click(function(e) {
        var newElement = {
          id: context.select.val(),
          label: context.select.find('option:selected').text()
        };

        addId(context, newElement.id);

        addElement(context, newElement, { refreshPosition: true });

        context.list.sortable('refresh');

        e.preventDefault(); e.stopPropagation();
      });
    }

    /* ___ Add an element into the list ___ */
    var addElement = function(context, data, options) {
      options = $.extend({
        'is_template': false,
        'refreshPosition': false
      }, options);

      data = $.extend({
        behaviour_flag: function() { return options.is_template ? 'template' : 'added' },
        base_name: function() { return options.is_template ? '' : context.baseInputName },
        if_template: function() { return options.is_template }
      }, data);

      var html = Mustache.to_html(context.template, data);

      var domElement = null;

      if (options.is_template) {
        domElement = context.list.append('<li class="sep">&nbsp;</li>').append(html).find('.template');

        context.sep = context.list.find('.sep');

        registerElementTemplateEvents(context, domElement);
      }
      else {
        domElement = context.list.find('> .sep').before(html).prev('li');

        registerElementEvents(context, data, domElement);

        context.error.hide();

        context.list.sortable('refresh');
      }
    }

    return this.each(function() {
      var wrapper = $(this);

      var context = {
        list: wrapper.find('ul'),
        empty: wrapper.find('p:first'),
        template: wrapper.find('script[name=template]').html(),
        baseInputName: wrapper.find('script[name=template]').attr('data-base-input-name'),
        data: eval(wrapper.find('script[name=data]').html()),
        error: wrapper.parent().find('p.inline-errors')
      };

      // sortable list
      context.list.sortable({
        handle: 'span.handle',
        items: 'li:not(.template)',
        axis: 'y'
      });

      // add the template element used to insert the new ones
      addElement(context, null, { is_template: true });

      context.select = wrapper.find('select[name=label]');
      populateSelect(context);

      for (var i = 0; i < context.data.taken_ids.length; i++) {
        var data = { id: context.data.taken_ids[i], label: null };

        for (var j = 0; j < context.data.collection.length; j++) {
          var current = context.data.collection[j];
          if (data.id == current[1])
            data.label = current[0];
        }

        addElement(context, data);
      }

      if (context.error.size() > 0)
        context.error.show();
    });
  };
})(jQuery);

