require 'spec_helper'

describe Locomotive::Snippet do

  let(:snippet) { build(:snippet) }

  it 'has a valid factory' do
    expect(snippet).to be_valid
  end

  # Validations ##

  %w{site name template}.each do |field|
    it "validates presence of #{field}" do
      snippet.send(:"#{field}=", nil)
      expect(snippet).to_not be_valid
      expect(snippet.errors[field.to_sym].first).to eq("can't be blank")
    end
  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { snippet }
    let(:attribute) { :template_version }

  end

end
