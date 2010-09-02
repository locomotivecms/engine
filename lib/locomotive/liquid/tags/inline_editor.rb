module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:inline_editor]
            %{
              <script src="/javascripts/admin/jquery.js" type="text/javascript"></script>
              <script src="/javascripts/admin/rails.js" type="text/javascript"></script>

              <script type="text/javascript" src="/javascripts/admin/aloha/aloha.js"></script>
              <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Format/plugin.js"></script>
              <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Table/plugin.js"></script>
              <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.List/plugin.js"></script>
              <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Link/plugin.js"></script>
              <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.HighlightEditables/plugin.js"></script>

              <script type="text/javascript" src="/javascripts/admin/inline_editor.js"></script>
            }
          end
        end
      end

      ::Liquid::Template.register_tag('inline_editor', InlineEditor)
    end
  end
end
