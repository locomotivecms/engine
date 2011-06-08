$(document).ready(function() {

  var wrapper = $('fieldset.editable-list.fields');
  var list = wrapper.find('ol');
  var template = wrapper.find('script[name=template]').html();
  var baseInputName = wrapper.find('script[name=template]').attr('data-base-input-name');
  var data = eval(wrapper.find('script[name=data]').html());
  var index = 0;

  var domFieldVal = function(domField, fieldName, val) {
    var el = domField.find('input[data-field=' + fieldName + '], select[data-field=' + fieldName + ']');
    return (typeof(val) == 'undefined' ? el.val() : el.val(val));
  }

  var domBoxAttr = function(fieldName) {
    return $('#fancybox-wrap form').find('input[name=custom_fields_field[' + fieldName + ']], select[name=custom_fields_field[' + fieldName + ']]');
  }

  var domBoxAttrVal = function(fieldName, val) {
    return (typeof(val) == 'undefined' ? domBoxAttr(fieldName).val() : domBoxAttr(fieldName).val(val));
  }

  /* ___ Register all the different events when a field is added (destroy, edit details, ...etc) ___ */

  var registerFieldEvents = function(field, domField) {
    // select
    domField.find('em').click(function() {
      $(this).hide();
      $(this).next().show();
    });

    domField.find('select').each(function() {
      var select = $(this);
      select.hover(function() {
        clearTimeout($.data(select, 'timer'));
      },
      function() {
        $.data(select, 'timer', setTimeout(function() {
          select.hide();
          select.prev().show();
        }, 1000));
      }).change(function() {
        selectOnChange(select);
      });
    });

    // checkbox
    domField.find('input[type=checkbox]').click(function() { domField.toggleClass('required'); });

    // edit
    domField.find('a.edit').click(function(e) {
      var link = $(this);
      var attributes = ['_alias', 'hint', 'text_formatting', 'target'];

      $.fancybox({
        titleShow: false,
        content: $(link.attr('href')).parent().html(),
        padding: 0,
        onComplete: function() {
          $('#fancybox-wrap .popup-actions button[type=submit]').click(function(e) {
            $.each(attributes, function(index, name) {
              var val = domBoxAttrVal(name).trim();
              if (val != '') domFieldVal(domField, name, val);
            });
            domBoxAttr('text_formatting').parent().hide();

            $.fancybox.close();
            e.preventDefault(); e.stopPropagation();
          });

          // copy current val to the form in the box
          $.each(attributes, function(index, name) {
            var val = domFieldVal(domField, name).trim();
            if (val == '' && name == '_alias') val = makeSlug(domFieldVal(domField, 'label'));

            domBoxAttrVal(name, val);
          });
          if (domFieldVal(domField, 'kind').toLowerCase() == 'text') domBoxAttr('text_formatting').parents('li').show();
          if (domFieldVal(domField, 'kind').toLowerCase() == 'has_one' ||
              domFieldVal(domField, 'kind').toLowerCase() == 'has_many') domBoxAttr('target').parents('li').show();
        }
      });
      e.preventDefault(); e.stopPropagation();
    });

    // remove
    domField.find('a.remove').click(function(e) {
      if (confirm($(this).attr('data-confirm'))) {
        if (field.new_record)
          domField.remove();
        else
          domField.hide().find('input[data-field=_destroy]').val(1);
        refreshPosition();
      }
      e.preventDefault(); e.stopPropagation();
    });
  }

  var registerFieldTemplateEvents = function(domField) {
    // checkbox
    domField.find('input[type=checkbox]').click(function() { domField.toggleClass('required'); });

    var labelDom = domField.find('input[data-field=label]').focus(function() {
      if ($(this).val() == data.template.label) $(this).val('');
    }).focusout(function() {
      if ($(this).val() == '') $(this).val(data.template.label);
    });
    var kindDom = domField.find('select[data-field=kind]');
    var requiredDom = domField.find('input[data-field=required]');

    // bind the "Add field" button
    domField.find('button').click(function(e) {
      var newField = $.extend({}, data.template);
      newField._alias = '';
      newField.label = labelDom.val().trim();
      newField.kind = kindDom.val();
      newField.required = requiredDom.is(':checked');

      if (newField.label == '' || newField.label == data.template.label) return false;

      // reset template values
      labelDom.val(data.template.label);
      kindDom.val(data.template.kind);
      requiredDom.attr('checked', '');
      domField.removeClass('required');

      addField(newField, { refreshPosition: true });

      e.preventDefault(); e.stopPropagation();
    });
  }

  var refreshPosition = function() {
    $.each(list.find('li.added:visible input[data-field=position]'), function(index) { $(this).val(index); });
  }

  var selectOnChange = function(select) {
    select.hide().prev()
      .show()
      .html(select[0].options[select[0].options.selectedIndex].text);
  }

  /* ___ Add a field in the list of fields ___ */
  var addField = function(field, options) {
    options = $.extend({
      'is_template': false,
      'refreshPosition': false
    }, options);

    field = $.extend({
      behaviour_flag: function() { return options.is_template ? 'template' : 'added' },
      new_record_flag: function() { return this.new_record == true && options.is_template == false ? 'new' : '' },
      errors_flag: function() { return Object.size(this.errors) > 0 ? 'error' : '' },
      required_flag: function() { return this.required ? 'required' : ''; },
      base_name: function() { return options.is_template ? '' : baseInputName + "[" + index + "]"; },
      base_dom_id: function() { return options.is_template ? 'custom_field_template' : 'custom_field_' + index; },
      required_checked: function() { return this.required ? 'checked' : ''; },
      if_existing_record: function() { return this.new_record == false }
    }, field);

    var html = Mustache.to_html(template, field);

    var domField = null;

    if (options.is_template) {
      domField = list.append(html).find('.template');

      registerFieldTemplateEvents(domField);
    }
    else {
      domField = list.find('> .template').before(html).prev('li');

      registerFieldEvents(field, domField);

      list.sortable('refresh');

      if (options.refreshPosition) refreshPosition();

      index++;
    }

    domField.find('select').val(field.kind);
    domField.find('em').html(domField.find('select option:selected').text());
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
    addField(data.template, { is_template: true });

    // add the existing fields (if present)
    for (var i = 0; i < data.collection.length; i++) {
      addField(data.collection[i]);
    }
  }

  setup(); // <- let the show begin
});