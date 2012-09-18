require 'spec_helper'

describe Locomotive::Liquid::Tags::Editable::ShortText do

  it 'accepts a valid syntax' do
    markup = "'title', hint: 'Simple short text'"
    lambda do
      Locomotive::Liquid::Tags::Editable::ShortText.new('editable_short_text', markup, ["{% endeditable_short_text %}"], {})
    end.should_not raise_error
  end

  it 'requires a slug' do
    lambda do
      Locomotive::Liquid::Tags::Editable::ShortText.new('editable_short_text', '', ["{% endeditable_short_text %}"], {})
    end.should raise_error(::Liquid::SyntaxError, "Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
  end

  describe '#default_element_attributes' do

    before(:each) do
      markup = "'title', hint: 'Simple short text'"
      @tag = Locomotive::Liquid::Tags::Editable::ShortText.new('editable_short_text', markup, ["{% endeditable_short_text %}"], {})
    end

    it 'returns a hash' do
      attributes = @tag.send(:default_element_attributes)
      attributes[:slug].should == 'title'
      attributes[:hint].should == 'Simple short text'
      attributes[:_type].should == 'Locomotive::EditableShortText'
    end

    it 'stores the default content' do
      @tag.instance_variable_set(:@nodelist, ['Lorem ipsum'])
      @tag.send(:default_element_attributes)[:content_from_default].should == 'Lorem ipsum'
    end

    it 'raises an exception if the default content contains liquid tags' do
      @tag.instance_variable_set(:@nodelist, ['hello ', ::Liquid::Variable.new("{{ 'world' }}")])
      lambda do
        @tag.send(:default_element_attributes)
      end.should raise_error(::Liquid::SyntaxError, "Error in the default block for the title editable_element - No liquid tags are allowed inside.")
    end

  end
  
end
