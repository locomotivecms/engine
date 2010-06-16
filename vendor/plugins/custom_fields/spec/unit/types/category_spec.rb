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
      @project.class.global_category_names.should == %w{Maintenance Design Development}
    end
    
    it 'sets the category from a name' do
      @project.global_category = 'Design'
      @project.global_category.should == 'Design'
      @project.field_1.should == '42'
    end
    
    it 'sets the category even it does not exit' do
      @project.global_category = 'Accounting'
      @project.global_category.should == 'Accounting'
      @project.field_1.should == 'Accounting'
    end
    
    context 'group by category' do
      
      before(:each) do
        seed_projects
        @groups = @project.class.group_by_global_category
      end
      
      it 'is an non empty array' do
        @groups.class.should == Array
        @groups.size.should == 3
      end
      
      it 'is an array of hash composed of a name' do
        @groups.collect { |g| g[:name] }.should == %w{Maintenance Design Development}
      end
      
      it 'is an array of hash composed of a list of objects' do
        @groups[0][:items].size.should == 0
        @groups[1][:items].size.should == 1
        @groups[2][:items].size.should == 2
      end
      
      it 'passes method to retrieve items' do
        @project.class.expects(:ordered)
        @project.class.group_by_global_category(:ordered)
      end
      
    end
        
  end
  
  def build_project_with_category
    field = build_category
    Project.to_klass_with_custom_fields(field).new
  end
  
  def build_category
    field = CustomFields::Field.new(:label => 'global_category', :_name => 'field_1', :kind => 'Category')
    field.stubs(:valid?).returns(true)
    field.category_items.build :name => 'Development', :_id => '41', :position => 2
    field.category_items.build :name => 'Design', :_id => '42', :position => 1
    field.category_items.build :name => 'Maintenance', :_id => '43', :position => 0
    field
  end
  
  def seed_projects
    list = [
      @project.class.new(:name => 'Locomotive CMS', :global_category => '41'),
      @project.class.new(:name => 'Ruby on Rails', :global_category => '41'),
      @project.class.new(:name => 'Dribble', :global_category => '42')
    ]
    @project.class.stubs(:all).returns(list)
  end
  
end