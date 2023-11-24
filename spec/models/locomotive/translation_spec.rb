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

  describe '.by_id_or_key' do
    let(:site) { create(:site) }

    before do
      create(:translation, key: 'first_translation', site: site)
      create(:translation, key: 'second_translation', site: site)
    end
    
    subject { site.translations.by_id_or_key(key).first }

    describe 'Given there is no translation in DB matching the key' do
      let(:key) { 'unknown' }

      it { is_expected.to eq nil }
    end

    describe 'Given there is a translation in DB matching the key' do
      let(:key) { 'first_translation' }

      it 'returns the section' do
        expect(subject.key).to eq 'first_translation'
      end
    end
  end

end
