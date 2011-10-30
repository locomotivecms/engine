// edit category collection
$(document).ready(function() {
  $('button.edit-categories-link').click(function() {
    var link = $(this);
    $.fancybox({
      titleShow: false,
      href: link.attr('data-url'),
      padding: 0,
      onComplete: function() { SetupCustomFieldCategoryEditor(link.prev()); },
      onCleanup: function() { }
    })
  });
});

var SetupCustomFieldCategoryEditor = function(target) {

  var wrapper = $('#edit-custom-field-category');
  var form = wrapper.find('form.formtastic');
  var submitButton = wrapper.find('.popup-actions button');
  var list = wrapper.find('ol');
  var template = $('#category-tmpl').html();
  var baseInputName = $('#category-tmpl').attr('data-base-input-name');
  var data = categories;
  var index = 0;

  var refreshPosition = function() {
    $.each(list.find('li.added:visible input[data-field=position]'), function(index) { $(this).val(index); });
  }

  var updateTargetCallback = function(data) {
    if (data.error == null) {
      list = data.category_items.sort(function(a, b) { return (a.position - b.position); });

      var options = '';
      var selectedValue = target.val();
      for (var i = 0; i < list.length; i++)
        options += '<option value="' + list[i].id + '" >' + list[i].name + '</option>';

      target.html(options);
      target.val(selectedValue);

      $.fancybox.close();
    } else
      $.growl("error", data.error);
  }

  var updateTarget = function(event) {
    $.ajax({
      type: 'PUT',
      dataType: 'json',
      data: form.serialize(),
      url: form.attr('action'),
      success: updateTargetCallback
    });
    event.preventDefault();
    event.stopPropagation();
  }

  var registerTemplateEvents = function(domField) {
    var nameDom = domField.find('input[data-field=name]');

    // bind the "Add field" button
    domField.find('button').bind('click', function(e) {
      var newItem = $.extend({}, data.template);
      newItem.name = nameDom.val().trim();

      if (newItem.name == '') return false;

      addItem(newItem, { refreshPosition: true });

      // reset template values
      nameDom.val('').focus();

      e.preventDefault(); e.stopPropagation();
    });

    nameDom.keypress(function(e) {
      if (e.which == 13) {
        domField.find('button').trigger('click');
        e.preventDefault();
      }
    });
  }

  var registerItemEvents = function(category, domField) {
    // remove
    domField.find('a.remove').click(function(e) {
      if (confirm($(this).attr('data-confirm'))) {
        if (category.new_record)
          domField.remove();
        else
          domField.hide().find('input[data-field=_destroy]').val(1);

        refreshPosition();

        $.fancybox.resize();
      }
      e.preventDefault(); e.stopPropagation();
    });
  }

  var addItem = function(category, options) {
    options = $.extend({
      'is_template': false,
      'refreshPosition': false
    }, options);

    category = $.extend({
      behaviour_flag: function() { return options.is_template ? 'template' : 'added' },
      new_record_flag: function() { return this.new_record == true && options.is_template == false ? 'new' : '' },
      errors_flag: function() { return this.errors && Object.size(this.errors) > 0 ? 'error' : '' },
      base_name: function() { return options.is_template ? '' : baseInputName + "[" + index + "]"; },
      base_dom_id: function() { return options.is_template ? 'category_template' : 'category_' + index; },
      if_existing_record: function() { return this.new_record == false }
    }, category);

    var html = Mustache.to_html(template, category);

    if (options.is_template) {
      domField = list.append(html).find('.template');

      registerTemplateEvents(domField);
    }
    else {
      domField = list.find('> .template').before(html).prev('li');

      registerItemEvents(category, domField);

      list.sortable('refresh');

      if (options.refreshPosition) refreshPosition();

      index++;
    }

    $.fancybox.resize();
  }

  /* ___ SETUP ___ */
  var setup = function() {
    // sortable list
    list.sortable({
      handle: 'span.handle',
      items: 'li:not(.template)',
      axis: 'y',
      update: refreshPosition
    });

    // add the template field used to insert the new ones
    addItem(data.template, { is_template: true });

    // add the existing fields (if present)
    for (var i = 0; i < data.collection.length; i++)
      addItem(data.collection[i]);

    submitButton.click(updateTarget);
   }

   setup(); // <- let's the show begin
};