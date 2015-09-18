require 'spec_helper'

describe Locomotive::Translation do

  let(:translation) { build(:translation) }

  it 'has a valid factory' do
    expect(translation).to be_valid
  end

  # Validations ##

  %w{site key}.each do |field|
    it "validates presence of #{field}" do
      translation.send(:"#{field}=", nil)
      expect(translation).to_not be_valid
      expect(translation.errors[field.to_sym].first).to eq("can't be blank")
    end
  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { translation }
    let(:attribute) { :content_version }

  end

end
