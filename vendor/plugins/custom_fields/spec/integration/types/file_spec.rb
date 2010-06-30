require 'spec_helper'

describe CustomFields::Types::File do
  
  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @project.task_custom_fields.build(:label => 'Screenshot', :_alias => 'screenshot', :kind => 'File')
    @project.save
    @task = @project.tasks.build
  end
  
  it 'attaches file' do
    @task.screenshot = FixturedFile.open('doc.txt')
    @task.save
    @task.screenshot.url.should == '/uploads/doc.txt'
  end
      
end