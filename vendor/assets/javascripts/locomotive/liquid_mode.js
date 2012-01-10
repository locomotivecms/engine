/*
  This overlay provides a 'liquid' mode to the excellent CodeMirror editor (http://codemirror.net/).
  Add something like this to your CSS:

    .cm-liquid-tag {
      color: #32273f;
      background: #ead9ff;
    }

    .cm-liquid-variable {
      color: #29739b
      background: #c2e0f0;
    }

  https://gist.github.com/1356686
*/

CodeMirror.defineMode("liquid", function(config, parserConfig) {
  var liquidOverlay = {
    token: function(stream, state) {

      // Variables.
      if (stream.match("{{")) {
        while ((ch = stream.next()) != null)
          if (ch == "}" && stream.next() == "}") break;
        return "liquid-variable";
      }

      // Tags.
      if(stream.match("{%")) {
        while ((ch = stream.next()) != null)
          if (ch == "%" && stream.next() == "}") break;
        return "liquid-tag";
      }

      while (stream.next() != null && !stream.match("{{", false) && !stream.match("{%", false)) {}
      return null;
    }
  };

  return CodeMirror.overlayParser(CodeMirror.getMode(config, parserConfig.backdrop || "text/html"), liquidOverlay);
});