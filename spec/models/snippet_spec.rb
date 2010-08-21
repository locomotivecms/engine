require 'spec_helper'

describe Snippet do

  it 'should have a valid factory' do
    Factory.build(:snippet).should be_valid
  end
  
  # Validations ##

  %w{site name template}.each do |field|
    it "should validate presence of #{field}" do
      template = Factory.build(:snippet, field.to_sym => nil)
      template.should_not be_valid
      template.errors[field.to_sym].should == ["can't be blank"]
    end
  end

end
