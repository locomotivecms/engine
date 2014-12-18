require 'spec_helper'

describe Locomotive::Liquid::Tags::Javascript do

  context '#validating syntax' do
    it 'validates a basic syntax' do
      expect do
        Locomotive::Liquid::Tags::Javascript.new('javascript', '', ["{% endjavascript %}"], {})
      end.to_not raise_error
    end
  end

  context '#rendering' do

    let(:template) { "{% javascript %}alert('Locomotive rocks!'){% endjavascript %}" }

    subject { Liquid::Template.parse(template).render }

    it { is_expected.to eq("<script>\n//<![CDATA[\nalert('Locomotive rocks!')\n//]]>\n</script>") }

  end
end
