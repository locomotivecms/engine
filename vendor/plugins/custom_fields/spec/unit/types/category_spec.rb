require 'spec_helper'

describe CustomFields::Types::Category do
  
  context 'on field class' do
    
    before(:each) do
      @field = CustomFields::Field.new
    end
    
    it 'has the category items field' do
      @field.respond_to?(:category_items).should be_true
    end
    
    it 'has the apply method used for the target object' do
      @field.respond_to?(:apply_category_type).should be_true
    end
    
  end
  
  context 'on target class' do
    
    before(:each) do
      @project = build_project_with_category
    end
    
    it 'has getter/setter' do
      @project.respond_to?(:global_category).should be_true
      @project.respond_to?(:global_category=).should be_true
    end
    
    it 'has the values of this category' do
      @project.class.global_category_names.should == %w{Development Design Maintenance}
    end
    
    it 'sets the category from a name' do
      @project.global_category = 'Design'
      @project.global_category.should == 'Design'
      @project.field_1.should_not be_nil
    end
        
  end
  
  def build_project_with_category
    field = build_category
    Project.to_klass_with_custom_fields(field).new
  end
  
  def build_category
    field = CustomFields::Field.new(:label => 'global_category', :_name => 'field_1', :kind => 'Category')
    field.stubs(:valid?).returns(true)
    field.category_items.build :name => 'Development'
    field.category_items.build :name => 'Design'
    field.category_items.build :name => 'Maintenance'
    field
  end
  
end