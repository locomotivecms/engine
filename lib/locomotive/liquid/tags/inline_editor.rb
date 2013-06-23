module Liquid
  module Locomotive
    module Tags
      class InlineEditor < ::Liquid::Tag

        def render(context)
          if context.registers[:current_locomotive_account] && context.registers[:inline_editor]

            plugins = 'common/ui,common/format,common/table,common/list,common/link,common/highlighteditables,common/block,common/undo,common/contenthandler,common/paste,common/commands,common/abbr,common/align,common/horizontalruler,common/image,custom/locomotive_media,custom/inputcontrol'

            controller = context.registers[:controller]
            controller.instance_variable_set(:@plugins, plugins)

            page = context.registers[:page].to_presenter.as_json_for_html_view
            page['lang'] = context['locale']

            html = <<-HTML
              %meta{ content: true, name: 'inline-editor' }

              = stylesheet_link_tag 'aloha/css/aloha.css'
              = javascript_include_tag 'locomotive/aloha', :'data-aloha-plugins' => @plugins

              %script{ type: 'text/javascript' }
                :plain
                  Aloha.ready(function() \{
                    window.parent.application_view.set_page(#{controller.view_context.escape_json page.to_json.html_safe});
                  \});
            HTML

            Haml::Engine.new(html.gsub(/\n+/, "\n").gsub(/^\s{14}/, ''), escape_html: true).render(controller.view_context)
          else
            ''
          end
        end
      end

      ::Liquid::Template.register_tag('inline_editor', InlineEditor)
    end
  end
end