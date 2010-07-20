require 'spec_helper'

describe CustomFields::CustomFieldsFor do
    
  context '#proxy class'  do
    
    before(:each) do
      @project = Project.new
      @klass = @project.tasks.klass
    end
    
    it 'returns the proxy class in the association' do
      @klass.should == @project.tasks.build.class
    end
    
    it 'has a link to the parent' do
      @klass._parent.should == @project
    end
    
    it 'has the association name which references to' do
      @klass.association_name.should == 'tasks'
    end
    
  end
    
  context 'with embedded collection' do
    
    context '#association' do
      
      before(:each) do
        @project = Project.new
      end
  
      it 'has custom fields for embedded collection' do
        @project.respond_to?(:task_custom_fields).should be_true
      end
            
    end
  
    context '#building' do
      
      before(:each) do
        @project = Project.new
        @project.task_custom_fields.build :label => 'Short summary', :_alias => 'summary', :kind => 'String'
        @task = @project.tasks.build
      end
      
      it 'returns a new document whose Class is different from the original one' do
        @task.class.should_not == Task
      end
      
      it 'returns a new document with custom field' do
        @project.tasks.build
        @project.tasks.build
        @task.respond_to?(:summary).should be_true
      end
      
      it 'sets/gets custom attributes' do
        @task.summary = 'Lorem ipsum...'
        @task.summary.should == 'Lorem ipsum...'
      end
      
    end
    
  end
  
  context 'with related collection' do
    
    context '#association' do
      
      before(:each) do
        @project = Project.new
      end
    
      it 'has custom fields for related collections' do
        @project.respond_to?(:person_custom_fields).should be_true
      end
      
    end
    
    context '#building' do
      
      before(:each) do
        @project = Project.new
        @project.person_custom_fields.build :label => 'Position in the project', :_alias => 'position', :kind => 'String'
        @person = @project.people.build
      end
      
      it 'returns a new document whose Class is different from the original one' do
        @person.class.should_not == Person
      end
      
      it 'returns a new document with custom field' do
        @person.respond_to?(:position).should be_true
      end
      
      it 'sets/gets custom attributes' do
        @person.position = 'Designer'
        @person.position.should == 'Designer'
      end
      
    end
    
  end
  
end