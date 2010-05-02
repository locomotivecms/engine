require 'spec_helper'
 
describe Snippet do
  
  it 'should have a valid factory' do
    Factory.build(:snippet).should be_valid
  end
  
end