require 'spec_helper'

describe Locomotive::Liquid::Drops::Tags do
  
   before(:each) do
    setup_tags
    @tagdrop = Locomotive::Liquid::Drops::Tags.new()
  end
  
  it 'should return a array of strings of all tags' do
    @tagdrop.available_tags.should include("red", "blue", "green", "yellow")
  end
  
  it 'should get a particular tag' do
    template = %({{tags.multiple-word.name}})
    render(template, {'tags' => @tagdrop }).should == "Multiple Word"
  end

  
  protected
  
  def setup_tags
    CustomFields::Types::TagSet::Tag.create(:name => "red");
    CustomFields::Types::TagSet::Tag.create(:name => "blue");
    CustomFields::Types::TagSet::Tag.create(:name => "green");
    CustomFields::Types::TagSet::Tag.create(:name => "yellow");
    CustomFields::Types::TagSet::Tag.create(:name => "Multiple Word");
    
  end
  
  def render(template, assigns = {})
    liquid_context = ::Liquid::Context.new(assigns, {}, {})
    
    output = ::Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end