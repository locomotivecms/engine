((wysihtml5) ->

  # New command: strike
  wysihtml5.commands.strike =
    exec: (composer, command) ->
      wysihtml5.commands.formatInline.exec(composer, command, 'STRIKE')

    state: (composer, command) ->
      wysihtml5.commands.formatInline.state(composer, command, 'STRIKE', null, null)

)(wysihtml5)


# New command: insert file
((wysihtml5) ->

  wysihtml5.commands.insertFile =
    exec: (composer, command, param) ->
      # do nothing
      # console.log "[insertFile] exec(#{command}, #{param})"

    state: (composer, command) ->
      # console.log "[insertFile] state(#{command})"
      wysihtml5.commands.insertImage.state(composer, command, "IMG")
      # wysihtml5.commands.formatBlock.state(composer, "formatBlock", null, CLASS_NAME, REG_EXP)

)(wysihtml5)

# Replace command: insert table
((wysihtml5) ->

  buildHeader = (cols) ->
    html = '<thead><tr>'
    html += '<th><br></th>' for col in [0...cols]
    html + '</tr></thead>'

  buildBody = (cols, rows) ->
    html = '<tbody>'
    for row in [0...rows]
      html += '<tr>'
      html += '<td><br></td>' for col in [0...cols]
      html += '</tr>'
    html += '</tbody>'

  wysihtml5.commands.createTable =
    exec: (composer, command, options) ->
      options = _.extend { cols: 3, rows: 3, class_name: '', head: true }, options

      cols = parseInt(options.cols, 10)
      rows = parseInt(options.rows, 10)

      html = "<table class='#{options.class_name}'>"
      html += buildHeader(cols) if options.head
      html += buildBody(cols, rows)
      html += '</table>'

      composer.commands.exec('insertHTML', html)

    state: (composer, command) ->
      false

)(wysihtml5)



