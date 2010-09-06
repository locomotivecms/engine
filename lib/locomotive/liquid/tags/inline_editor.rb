module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:current_admin]
            output = %{
              <meta name="locale" content="#{context.registers[:current_admin].locale}" />
              <meta name="page-fullpath" content="/#{context.registers[:page].fullpath}" />
              <meta name="edit-page-url" content="#{context.registers[:controller].send(:edit_admin_page_url, context.registers[:page])}" />
            }

            if context.registers[:inline_editor]
              controller = context.registers[:controller]

              output << %{
                <meta name="page-url" content="#{context.registers[:controller].send(:admin_page_url, context.registers[:page], :json)}" />
                <meta name="page-elements-count" content="#{context.registers[:page].editable_elements.size}" />

                <script type="text/javascript" src="/javascripts/admin/aloha/aloha.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Format/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Table/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.List/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.Link/plugin.js"></script>
                <script type="text/javascript" src="/javascripts/admin/aloha/plugins/com.gentics.aloha.plugins.HighlightEditables/plugin.js"></script>
              }

              if controller.send(:protect_against_forgery?)
                output << %(<meta name="csrf-param" content="#{Rack::Utils.escape_html(controller.send(:request_forgery_protection_token))}"/>\n<meta name="csrf-token" content="#{Rack::Utils.escape_html(controller.send(:form_authenticity_token))}"/>).html_safe
              end
            else
              output << %{
                <script src="/javascripts/admin/jquery.js" type="text/javascript"></script>
                <script src="/javascripts/admin/plugins/cookie.js" type="text/javascript"></script>
              }
            end

            output << %{
              <script src="/javascripts/admin/rails.js" type="text/javascript"></script>
              <script type="text/javascript" src="/javascripts/admin/inline_editor_toolbar.js"></script>
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
