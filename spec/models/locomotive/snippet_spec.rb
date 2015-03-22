require 'spec_helper'

describe Locomotive::Snippet do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:snippet)).to be_valid
  end

  # Validations ##

  %w{site name template}.each do |field|
    it "validates presence of #{field}" do
      template = FactoryGirl.build(:snippet, field.to_sym => nil)
      expect(template).to_not be_valid
      expect(template.errors[field.to_sym]).to eq(["can't be blank"])
    end
  end

end
