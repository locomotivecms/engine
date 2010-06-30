require 'spec_helper'

describe CustomFields::Types::Date do
  
  context 'on field class' do
    
    before(:each) do
      @field = CustomFields::Field.new
    end
    
    it 'returns true if it is a Date' do
      @field.kind = 'File'
      @field.file?.should be_true
    end
    
    it 'returns false if it is not a Date' do
      @field.kind = 'string'
      @field.file?.should be_false
    end
    
  end
  
end