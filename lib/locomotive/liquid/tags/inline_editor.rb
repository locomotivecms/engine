module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:current_locomotive_account] && context.registers[:inline_editor]
            %{
              <meta content="true" name="inline-editor" />
              <link href="/assets/locomotive/aloha/css/aloha.css" media="screen" rel="stylesheet" type="text/css" />
              <script type="text/javascript" src="/assets/locomotive/utils/aloha_settings.js"></script>
              <script type="text/javascript" src="/assets/locomotive/aloha/lib/aloha.js" data-aloha-plugins="common/format,common/highlighteditables,common/list,common/link,common/undo,common/paste"></script>

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
