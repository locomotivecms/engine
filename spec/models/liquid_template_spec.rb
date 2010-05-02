require 'spec_helper'
 
describe LiquidTemplate do
  
  it 'should have a valid factory' do
    Factory.build(:liquid_template).should be_valid
  end
  
  # Validations ##
  
  %w{site name slug value}.each do |field|
    it "should validate presence of #{field}" do
      template = Factory.build(:liquid_template, field.to_sym => nil)
      template.should_not be_valid
      template.errors[field.to_sym].should == ["can't be blank"]
    end
  end

end