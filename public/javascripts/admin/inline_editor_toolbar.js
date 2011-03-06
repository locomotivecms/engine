var InlineEditorToolbar = {

  element: null, // reference to the toolbar element

  form: null, // reference to the form used to post changes

  editingMode: false, // true means that Aloha should be enabled

  drawerButton: null,

  locale: 'en', // default locale

  initialize: function() {
    this.editingMode = window.location.href.match(/\/edit$/) != null;
    this.locale = $('meta[name=locale]').attr('content');

    this._buildHTML();

    this.element = $('#page-toolbar');
    this.form = this.element.find('form');
    this.drawerButton = this.element.find('.drawer a');

    this._bindEvents();

    if ($.cookie('ie_toolbar_off') == '1') this.hide(0, false);
  },

  toggle: function(animate) {
    var duration = (typeof animate == 'undefined') || animate == true ? 300 : 0;

    if (this.drawerButton.hasClass('off')) this.show(duration); else this.hide(duration);
  },

  show: function(duration, withCookie) {
    var self = this;

    this.element.animate({ 'right': 0 }, duration, function() {
      self.drawerButton.removeClass('off');
      if ((typeof withCookie == 'undefined') || withCookie == true)
        $.cookie('ie_toolbar_off', '0');
    });
  },

  hide: function(duration, withCookie) {
    var self = this;
    var max = this.element.width() - 17;

    this.element.animate({ 'right': -max }, duration, function() {
      self.drawerButton.addClass('off');
      if ((typeof withCookie == 'undefined') || withCookie == true)
        $.cookie('ie_toolbar_off', '1');
    });
  },

  updateForm: function(jEvent, aEvent) {
    InlineEditorToolbar.element.find('li.save, li.cancel, li.sep:eq(1)').show();
    InlineEditorToolbar.element.find('')

    var editableObj = $(aEvent.editable.obj[0]);
    var index = editableObj.attr('data-element-index');
    var input = InlineEditorToolbar.form.find('#editable-' + index);

    input.attr('name', input.attr('name').replace('_index', 'content'));
    input.val(aEvent.editable.getContents().replace(/^\s*/, "").replace(/\s*$/, ""));

    InlineEditorToolbar.show(true, false);
  },

  displaySpinner: function() {
    this.element.find('li.save, li.cancel, li.sep:eq(1)').hide();
    this.element.find('.spinner').show();
  },

  resetForm: function() {
    this.form.find('input.auto').each(function() {
      $(this).attr('name', $(this).attr('name').replace('content', '_index'));
      $(this).val('');
    });

    this.element.find('li.save, li.cancel, li.sep:eq(1), li.spinner').hide();
  },

  /* ___ internal methods ___ */

  _buildHTML: function() {
    var labels = this._translations[this.locale];

    var showPageUrl = $('meta[name=page-url]').attr('content');
    var editPageUrl = $('meta[name=edit-page-url]').attr('content');
    var nbElements = parseInt($('meta[name=page-elements-count]').attr('content'));

    var formContentHTML = "<input type='hidden' name='_method' value='put' />";
    for (var i = 0; i < nbElements; i++) {
      formContentHTML += "<input class='auto' id='editable-" + i + "' type='hidden' name='page[editable_elements_attributes][" + i + "][_index]' value='' />";
    }

    $('body').prepend("<div id='page-toolbar'>\
      <ul>\
        <li class='drawer'><a href='#'><span>&nbsp;</span></a></li>\
        <li class='link home'><a href='" + editPageUrl + "'><span>" + labels['home'] + "</span></a></li>\
        <li class='sep'><span>&nbsp;</span></li>\
        <li class='link edit' style='" + (this.editingMode ? 'display: none' : '') + "'><a href='#'><span>" + labels['edit'] + "</span></a></li>\
        <li class='link save' style='display: none'><a href='#'><span>" + labels['save'] + "</span></a></li>\
        <li class='link cancel' style='display: none'><a href='#'><span>" + labels['cancel'] + "</span></a></li>\
        <li class='link spinner' style='display: none'><a href='#'><span><img src='/images/admin/form/spinner.gif' /><em>" + labels['saving'] + "</em></span></a></li>\
        <li class='sep' style='display: none'><span>&nbsp;</span></li>\
        <li class='link back' style='" + (this.editingMode ? '' : 'display: none') + "'><a href='#'><span>" + labels['back'] + "</span></a></li>\
      </ul>\
      <form action='" + showPageUrl + "' accept-charset='UTF-8' method='post'>\
        " + formContentHTML + "\
      </form>\
    </div>");
  },

  _bindEvents: function() {
    var self = this;
    var fullpath = $('meta[name=page-fullpath]').attr('content');

    this.form.live('submit', function (e) { $(this).callRemote(); e.stopPropagation(); e.preventDefault();
    }).bind('ajax:complete', function() { self.resetForm();
    }).bind('ajax:loading', function() { self.displaySpinner();
    }).bind('ajax:failure', function() { self.resetForm();
    });

    this.element.find('ul li a').click(function(e) {
      var classArray = $(this).parent().attr('class').split(' ');
      switch(classArray[1] || classArray[0]) {
        case 'home':
          window.location.href = $(this).attr('href'); break;

        case 'edit': // passing in editing mode
          var url = window.location.href.replace(/\/$/, '/index').replace('#', '');
          window.location.href = url + '/edit'; break;

        case 'save': // saving changes
          self.form.submit(); break;

        case 'cancel': // reload the page
          window.location.href = window.location.href; break;

        case 'back': // back to the non edition mode
          window.location.href = fullpath; break;

        case 'drawer': // expand / shrink toolbar
          self.toggle(); break;
      }

      e.preventDefault(); e.stopPropagation();
    });
  },

  _translations: {
    'en': {
      'home': 'admin',
      'edit': 'edit',
      'save': 'save',
      'cancel': 'cancel',
      'back': 'edition done',
      'saving': 'saving'
    },
    'de': {
      'home': 'admin',
      'edit': 'bearbeiten',
      'save': 'speichern',
      'cancel': 'schließen',
      'back': 'bearbeiten abschließen',
      'saving': 'am Speichern'
    },    
    'fr': {
      'home': 'admin',
      'edit': 'editer',
      'save': 'sauver',
      'cancel': 'annuler',
      'back': 'fin mode edition',
      'saving': 'sauvegarde en cours'
    },
		'pt-BR': {
      'home': 'admin',
      'edit': 'editar',
      'save': 'salvar',
      'cancel': 'cancelar',
      'back': 'terminar edição',
      'saving': 'salvando'
    }
  }
};