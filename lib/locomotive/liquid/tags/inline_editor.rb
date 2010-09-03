module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:current_admin]
            output = %{
              <meta name="page-fullpath" content="/#{context.registers[:page].fullpath}" />
              <meta name="edit-page-url" content="#{context.registers[:controller].send(:edit_admin_page_url, context.registers[:page])}" />

              <script src="/javascripts/admin/jquery.js" type="text/javascript"></script>
              <script src="/javascripts/admin/rails.js" type="text/javascript"></script>
            }

            if context.registers[:inline_editor]
              output << %{
                <meta name="page-url" content="#{context.registers[:controller].send(:admin_page_url, context.registers[:page])}" />

                <script type="text/javascript" src="/javascripts/admin/aloha/aloha.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Format/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Table/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.List/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Link/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.HighlightEditables/plugin.js"></script>
              }
            end

            output << %{
              <script type="text/javascript" src="/javascripts/admin/inline_editor.js"></script>
              <link href="/stylesheets/admin/inline_editor.css" media="screen" rel="stylesheet" type="text/css" />
            }
          end
        end
      end

      ::Liquid::Template.register_tag('inline_editor', InlineEditor)
    end
  end
end
