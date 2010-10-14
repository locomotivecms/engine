module Liquid
  module Locomotive
    module Tags
      class GoogleAnalytics < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @account_id = $1.gsub('\'', '')
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'google_analytics' - Valid syntax: google_analytics <account_id>")
          end

          super
        end

        def render(context)
          %{
          <script type="text/javascript">

            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '#{@account_id}']);
            _gaq.push(['_trackPageview']);

            (function() \{
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            \})();

          </script>}
        end
      end

      ::Liquid::Template.register_tag('google_analytics', GoogleAnalytics)
    end
  end
end
