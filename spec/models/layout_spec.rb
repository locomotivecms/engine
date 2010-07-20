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
  
  context 'dealing with page parts' do
    
    before(:each) do
      @layout = Factory.build(:layout)
    end
    
    it 'should have 2 parts' do
      @layout.send(:build_parts_from_value)
      @layout.parts.size.should == 2
      
      @layout.parts.first.name.should == 'Body'
      @layout.parts.first.slug.should == 'layout'
      
      @layout.parts.last.name.should == 'Left sidebar'
      @layout.parts.last.slug.should == 'left_sidebar'
    end
    
    it 'should not add parts to pages if layout does not change' do
      @layout.stubs(:value_changed?).returns(false)
      page = Factory.build(:page, :layout => @layout, :site => nil)
      page.expects(:update_parts!).never
      @layout.pages << page
      @layout.save
    end
      
    it 'should add parts to pages if layout changes' do
      @layout.value = @layout.value + "..." 
      page = Factory.build(:page, :layout => @layout, :site => nil)
      page.expects(:update_parts!)
      @layout.pages << page
      @layout.save
    end
    
  end
  
  context 'parsing liquid template' do
    
    before(:each) do
      @layout = Factory.build(:layout)
    end
    
    it 'should not raise an error if template is empty' do
      @layout.template.should be_nil
    end
    
  end
  
end