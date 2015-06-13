# New command: strike
wysihtml5.commands.strike =
  exec: (composer, command, param) ->
    wysihtml5.commands.formatInline.exec(composer, command, 'strike')

  state: (composer, command) ->
     wysihtml5.commands.formatInline.state(composer, command, 'strike')

# New command: justify full
# https://github.com/xing/wysihtml5/blob/56960b31adc37e07797382d8e8b10109f206b19c/src/commands/justifyFull.js
((wysihtml5) ->
  CLASS_NAME  = "wysiwyg-text-align-justify"
  REG_EXP     = /wysiwyg-text-align-[0-9a-z]+/g

  wysihtml5.commands.justifyFull =
    exec: (composer, command, param) ->
      wysihtml5.commands.formatBlock.exec(composer, 'formatBlock', null, CLASS_NAME, REG_EXP)

    state: (composer, command) ->
      wysihtml5.commands.formatBlock.state(composer, "formatBlock", null, CLASS_NAME, REG_EXP)

)(wysihtml5)

# New command: insert file
((wysihtml5) ->

  wysihtml5.commands.insertFile =
    exec: (composer, command, param) ->
      # do nothing
      console.log "[insertFile] exec(#{command}, #{param})"

    state: (composer, command) ->
      # console.log "[insertFile] state(#{command})"
      wysihtml5.commands.insertImage.state(composer, command, "IMG")
      # wysihtml5.commands.formatBlock.state(composer, "formatBlock", null, CLASS_NAME, REG_EXP)

)(wysihtml5)


