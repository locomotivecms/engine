window.Aloha = window.Aloha ?= {}

window.Aloha.settings =

  logLevels: { 'error': true, 'warn': true, 'info': false, 'debug': false }

  errorhandling: true

  plugins:

    format:
      config: [ 'b', 'i', 'u','del','sub','sup', 'p', 'title', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'pre', 'removeFormat']
      editables:
        '.editable-short-text' : [ 'b', 'i', 'u' ]

    link:
      config: [ 'a' ]
      editables:
        '.editable-short-text': [ ]

    list:
      config: [ 'ul' ]
      editables:
        '.editable-short-text': [ ]

    image:
      ui:
        insert: false
        crop:   false

  i18n:
    available: ['en', 'fr', 'pt-BR', 'es', 'de', 'no', 'ru', 'nl']

  sidebar:
    disabled: true


