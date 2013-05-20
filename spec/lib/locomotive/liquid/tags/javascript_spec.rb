require 'spec_helper'

describe Locomotive::Liquid::Tags::Javascript do

  context '#validating syntax' do
    it 'validates a basic syntax' do
      lambda do
        Locomotive::Liquid::Tags::Javascript.new('javascript', '', ["{% endjavascript %}"], {})
      end.should_not raise_error
    end
  end
  
  context '#rendering' do
    template = "{% javascript %}alert('Locomotive rocks!'){% endjavascript %}"
    rendered = "<script type=\"text/javascript\">\n//<![CDATA[\nalert('Locomotive rocks!')\n//]]>\n</script>"
    Liquid::Template.parse(template).render.should == rendered
  end
end