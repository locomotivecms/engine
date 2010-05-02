require 'spec_helper'
 
describe Layout do
  
  it 'should have a valid factory' do
    Factory.build(:layout).should be_valid
  end
  
  ## validations ##
  
  it 'should validate presence of content_for_layout in value' do
    layout = Factory.build(:layout, :value => 'without content_for_layout')
    layout.should_not be_valid
    layout.errors[:value].should == ["should contain 'content_for_layout' liquid tag"]
  end
  
  describe 'once created' do
    
    before(:each) do
      @layout = Factory(:layout)
    end
    
    it 'should have 2 parts' do
      @layout.parts.count.should == 2
      
      @layout.parts.first.name.should == 'Body'
      @layout.parts.first.slug.should == 'layout'
      
      @layout.parts.last.name.should == 'Left Sidebar'
      @layout.parts.last.slug.should == 'sidebar'
    end
    
  end
  
end