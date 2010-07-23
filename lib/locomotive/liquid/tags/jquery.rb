module Liquid
  module Locomotive
    module Tags
      class Jquery < ::Liquid::Tag

        def render(context)
          %{
            <script src="/javascripts/jquery.js" type="text/javascript"></script>
            <script src="/javascripts/jquery.ui.js" type="text/javascript"></script>
          }
        end
      end

      ::Liquid::Template.register_tag('jQuery', Jquery)
    end
  end
end
