module Locomotive
  module Liquid
    module Tags
      class EscapeJavascript < ::Liquid::Block
        
        include ActionView::Helpers::JavaScriptHelper
        include ActionView::Helpers::TagHelper
        
        def render(context)
          javascript_tag super
        end
      end
      ::Liquid::Template.register_tag('escape_javascript', EscapeJavascript)
    end
  end
end