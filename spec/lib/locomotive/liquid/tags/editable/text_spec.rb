require 'spec_helper'

describe Locomotive::Liquid::Tags::Editable::Text do

  let(:markup) { "'title', hint: 'Simple short text'" }
  subject { build_tag }

  context 'valid syntax' do

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end

  end

  context 'without a slug' do

    let(:markup) { '' }

    it 'requires a slug' do
      expect { subject }.to raise_error(::Liquid::SyntaxError, "Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
    end

  end

  describe '.default_element_attributes' do

    let(:content) { '' }
    subject { build_tag('text', content).send(:default_element_attributes) }

    it { should include(slug: 'title') }
    it { should include(hint: 'Simple short text') }
    it { should include(_type: 'Locomotive::EditableText') }
    it { should include(format: 'html') }
    it { should include(rows: 10) }
    it { should include(line_break: true) }

    describe 'default content' do

      context 'only text' do

        let(:content) { 'Lorem ipsum' }
        it { should include(content_from_default: 'Lorem ipsum') }

      end

      context 'liquid tags' do

        let(:content) { ['hello ', ::Liquid::Variable.new("{{ 'world' }}")] }
        it { expect { subject }.to raise_error(::Liquid::SyntaxError, "Error in the default block for the title editable_element - No liquid tags are allowed inside.") }

      end

    end

    context 'editable_short_text' do

      subject { build_tag('short_text').send(:default_element_attributes) }

      it { should include(format: 'raw') }
      it { should include(rows: 2) }
      it { should include(line_break: false) }

    end

    context 'editable_long_text' do

      subject { build_tag('long_text').send(:default_element_attributes) }

      it { should include(format: 'html') }
      it { should include(rows: 15) }
      it { should include(line_break: true) }

    end

  end

  def build_tag(tag_name = 'text', content = nil)
    klass = "Locomotive::Liquid::Tags::Editable::#{tag_name.camelize}".constantize
    klass.new("editable_#{tag_name}", markup, ["{% endeditable_#{tag_name} %}"], {}).tap do |tag|
      tag.instance_variable_set(:@nodelist, [*content]) if content
    end
  end

end