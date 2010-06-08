require 'spec_helper'

describe CustomFields::Field do
  
  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end
  
  context '#mongoid' do
    
    before(:each) do
      @field = CustomFields::Field.new(:label => 'manager', :_name => 'field_1', :kind => 'String', :_alias => 'manager')
      @field.stubs(:valid?).returns(true)
      @project = Project.to_klass_with_custom_fields(@field).new
    end
    
    it 'is added to the list of mongoid fields' do
      @project.fields['field_1'].should_not be_nil
    end
    
  end
  
  context 'on target class' do
    
    before(:each) do
      @field = CustomFields::Field.new(:label => 'manager', :_name => 'field_1', :kind => 'String', :_alias => 'manager')
      @field.stubs(:valid?).returns(true)
      @project = Project.to_klass_with_custom_fields(@field).new
    end
    
    it 'has a new field' do
      @project.respond_to?(:manager).should be_true
    end
    
    it 'sets / retrieves a value' do
      @project.manager = 'Mickael Scott'
      @project.manager.should == 'Mickael Scott'
    end
    
  end
  
end