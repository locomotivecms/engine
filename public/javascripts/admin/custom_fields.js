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
      var attributes = ['_alias', 'hint', 'text_formatting'];

      $.fancybox({
        titleShow: false,
        content: $(link.attr('href')).parent().html(),
        padding: 0,
        onComplete: function() {
          $('#fancybox-wrap .actions button[type=submit]').click(function(e) {
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
      errors_flag: function() { return this.errors.length > 0 ? 'error' : '' },
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

  setup(); // <- let's the show begin
});

// $(document).ready(function() {
//
//   $('fieldset.fields').parents('form').submit(function() {
//     $('fieldset.fields li.template input, fieldset.fields li.template select').attr('disabled', 'disabled');
//   });
//
//   var defaultValue = $('fieldset.fields li.template input[type=text]').val();
//   var selectOnChange = function(select) {
//     select.hide();
//     select.prev()
//       .show()
//       .html(select[0].options[select[0].options.selectedIndex].text);
//   }
//
//   var refreshPosition = function() {
//     jQuery.each($('fieldset.fields li.added input.position'), function(index) {
//       $(this).val(index);
//     });
//   }
//
//   /* __ fields ___ */
//   $('fieldset.fields li.added select').each(function() {
//     var select = $(this)
//       .hover(function() {
//         clearTimeout(select.attr('timer'));
//       }, function() {
//         select.attr('timer', setTimeout(function() {
//           select.hide();
//           select.prev().show();
//         }, 1000));
//       })
//       .change(function() { selectOnChange(select); });
//
//     select.prev().click(function() {
//       $(this).hide();
//       select.show();
//     });
//   });
//
//   $('fieldset.fields li.template input[type=text]').focus(function() {
//     if ($(this).hasClass('void') && $(this).parents('li').hasClass('template'))
//       $(this).val('').removeClass('void');
//   });
//
//   $('fieldset.fields li.template button').click(function() {
//     var lastRow = $(this).parents('li.template');
//
//     var label = lastRow.find('input.label').val().trim();
//     if (label == '' || label == defaultValue) return false;
//
//     var newRow = lastRow.clone(true).removeClass('template').addClass('added new').insertBefore(lastRow);
//
//     var dateFragment = '[' + new Date().getTime() + ']';
//     newRow.find('input, select').each(function(index) {
//       $(this).attr('name', $(this).attr('name').replace('[-1]', dateFragment));
//     });
//
//     var select = newRow.find('select')
//       .val(lastRow.find('select').val())
//       .change(function() { selectOnChange(select); })
//       .hover(function() {
//         clearTimeout(select.attr('timer'));
//       }, function() {
//         select.attr('timer', setTimeout(function() {
//           select.hide();
//           select.prev().show();
//         }, 1000));
//       });
//     select.prev()
//       .html(select[0].options[select[0].options.selectedIndex].text)
//       .click(function() {
//         $(this).hide();
//         select.show();
//       });
//
//     // then "reset" the form
//     lastRow.find('input.label').val(defaultValue).addClass('void');
//
//     // warn the sortable widget about the new row
//     $("fieldset.fields ol").sortable('refresh');
//
//     refreshPosition();
//   });
//
//   $('fieldset.fields li a.remove').click(function(e) {
//     if (confirm($(this).attr('data-confirm'))) {
//       var parent = $(this).parents('li');
//
//       if (parent.hasClass('new'))
//         parent.remove();
//       else {
//         var field = parent.find('input.position')
//         field.attr('name', field.attr('name').replace('[position]', '[_destroy]'));
//
//         parent.hide().removeClass('added')
//       }
//
//       refreshPosition();
//     }
//
//     e.preventDefault();
//     e.stopPropagation();
//   });
//
//   // sortable list
//   $("fieldset.fields ol").sortable({
//     handle: 'span.handle',
//     items: 'li:not(.template)',
//     axis: 'y',
//     update: refreshPosition
//   });
//
//   // edit in depth custom field
//   $('fieldset.fields li.item span.actions a.edit').click(function() {
//     var link = $(this);
//     $.fancybox({
//       titleShow: false,
//       content: $(link.attr('href')).parent().html(),
//       onComplete: function() {
//         $('#fancybox-wrap form').submit(function(e) {
//           $.fancybox.close();
//           e.preventDefault();
//           e.stopPropagation();
//         });
//
//         var parent = link.parent();
//
//         if (parent.prevAll('select').val() == 'Text') {
//           var formatting = parent.prevAll('.text-formatting').val();
//           $('#fancybox-wrap #custom_fields_field_text_formatting').val(formatting);
//           $('#fancybox-wrap #custom_fields_field_text_formatting_input').show();
//         } else {
//           $('#fancybox-wrap #custom_fields_field_text_formatting_input').hide();
//         }
//
//         var alias = parent.prevAll('.alias').val().trim();
//         if (alias == '') alias = makeSlug(link.parent().prevAll('.label').val());
//         $('#fancybox-wrap #custom_fields_field__alias').val(alias);
//
//         var hint = parent.prevAll('.hint').val();
//         $('#fancybox-wrap #custom_fields_field_hint').val(hint);
//       },
//       onCleanup: function() {
//         var parent = link.parent();
//
//         var alias = $('#fancybox-wrap #custom_fields_field__alias').val().trim();
//         if (alias != '') parent.prevAll('.alias').val(alias);
//         var hint = $('#fancybox-wrap #custom_fields_field_hint').val().trim();
//         if (hint != '') parent.prevAll('.hint').val(hint);
//         var formatting = $('#fancybox-wrap #custom_fields_field_text_formatting').val();
//         parent.prevAll('.text-formatting').val(formatting);
//       }
//     })
//   });
// });
