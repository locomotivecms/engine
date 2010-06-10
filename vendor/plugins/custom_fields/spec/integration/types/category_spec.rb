require 'spec_helper'

describe CustomFields::Types::Category do
  
  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @field = @project.task_custom_fields.build(:label => 'Main category', :_alias => 'main_category', :kind => 'Category')
  end
    
  context 'saving category items' do

    before(:each) do
      @field.category_items.build :name => 'Development'
      @field.category_items.build :name => 'Design'
      @field.updated_at = Time.now
    end
  
    it 'persists items' do
      @field.save.should be_true
      @project.reload
      @project.task_custom_fields.first.category_items.size.should == 2
    end
    
  end
  
end