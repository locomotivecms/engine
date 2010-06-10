require 'spec_helper'

describe CustomFields::CustomFieldsFor do
  
  describe 'Saving' do
    
    before(:each) do
      @project = Project.new(:name => 'Locomotive')
      @project.person_custom_fields.build(:label => 'E-mail', :_alias => 'email', :kind => 'String')
      @project.person_custom_fields.build(:label => 'Age', :_alias => 'age', :kind => 'String')
    end
    
    context '@create' do
    
      it 'persists parent object' do
        lambda { @project.save }.should change(Project, :count).by(1)
      end
    
      it 'persists custom fields' do
        @project.save && @project.reload
        @project.person_custom_fields.count.should == 2
      end
    
    end
    
  end
  
end