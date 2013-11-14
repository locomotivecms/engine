window.Aloha = window.Aloha ?= {}

window.Aloha.settings =

  logLevels: { 'error': true, 'warn': true, 'info': false, 'debug': false }

  errorhandling: true

  plugins:

    format:
      config: ['b', 'i', 'u', 'del', 'sub', 'sup', 'p', 'title', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre', 'removeFormat']
      editables:
        '.editable-single-text': ['b', 'i', 'u', 'del', 'sub', 'sup']

    inputcontrol:
      editables:
        '.editable-single-text':
          disableEnter: true

    link:
      config: ['a']

    list:
      config: ['ul']
      editables:
        '.editable-single-text': []

    align:
      config:
        alignment: ['right','left','center','justify']
      editables:
        '.editable-single-text':
          alignment: []

    image:
      ui:
        insert: false
        crop:   false

  i18n:
    available: ['en', 'fr', 'pl', 'pt-BR', 'es', 'de', 'no', 'ru', 'nl', 'ja', 'cs', 'bg']

  sidebar:
    disabled: true

  toolbar:
    tabs:
      [
        {
          label: 'tab.format.label'
        },
        {
          label: 'tab.insert.label',
          showOn: { scope: 'Aloha.continuoustext' },
          exclusive: true,
          components: [
            [
              'createTable', 'characterPicker', 'insertLink',
              'insertAbbr', 'insertToc','insertHorizontalRule',
              'insertTag', 'insertlocomotivemedia'
            ]
          ]
        }
      ]
