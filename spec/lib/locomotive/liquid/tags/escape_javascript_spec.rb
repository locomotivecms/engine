require 'spec_helper'

describe Locomotive::Liquid::Tags::EscapeJavascript do

  context '#validating syntax' do
    it 'validates a basic syntax' do
      lambda do
        Locomotive::Liquid::Tags::EscapeJavascript.new('escape_javascript', '', ["{% endescape_javascript %}"], {})
      end.should_not raise_error
    end
  end
  
  context '#rendering' do
    template = "{% escape_javascript %}alert('Locomotive rocks!'){% endescape_javascript %}"
    rendered = "<script type=\"text/javascript\">\n//<![CDATA[\nalert('Locomotive rocks!')\n//]]>\n</script>"
    Liquid::Template.parse(template).render.should == rendered
  end
end