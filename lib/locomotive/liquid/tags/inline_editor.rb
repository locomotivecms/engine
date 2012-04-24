module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:current_locomotive_account] && context.registers[:inline_editor]

            controller = context.registers[:controller]

            plugins = 'common/format,common/table,common/list,common/link,common/highlighteditables,common/block,common/undo,common/contenthandler,common/paste,common/commands,common/abbr,common/align,common/horizontalruler,custom/locomotive_media'

            %{
              <meta content="true" name="inline-editor" />

              #{controller.view_context.stylesheet_link_tag    'aloha/css/aloha.css'}
              #{controller.view_context.javascript_include_tag 'locomotive/aloha', :'data-aloha-plugins' => plugins}

              <script type="text/javascript">
                Aloha.ready(function() \{
                  window.parent.application_view.set_page(#{context.registers[:page].to_presenter.as_json_for_html_view.to_json});
                \});
              </script>

            }
          else
            ''
          end
        end
      end

      ::Liquid::Template.register_tag('inline_editor', InlineEditor)
    end
  end
end