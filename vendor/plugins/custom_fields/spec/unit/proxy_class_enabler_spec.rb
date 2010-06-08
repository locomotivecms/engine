require 'spec_helper'

describe CustomFields::ProxyClassEnabler do
  
  context '#proxy klass' do
  
    before(:each) do
      @klass = Task.to_klass_with_custom_fields([])
    end
  
    it 'does not be flagged as a inherited document' do
      @klass.new.hereditary?.should be_false
    end
    
    it 'has a list of custom fields' do
      @klass.custom_fields.should == []
    end
    
    it 'has the exact same model name than its parent' do
      @klass.model_name.should == 'Task'
    end
  
  end
  
end