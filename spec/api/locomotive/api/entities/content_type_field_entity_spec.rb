require 'spec_helper'

describe Locomotive::API::Entities::ContentTypeFieldEntity do

  subject { described_class }

  attributes =
    %i(
      name
      type
      label
      hint
      required
      localized
      unique
      position
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do

    let!(:field) { build(:field) }
    let(:exposure) { subject.serializable_hash }

    subject { described_class.new(field) }

    describe 'text_formatting' do
      let!(:field) { build('text field') }
      it 'returns the correct formatting' do
        expect(exposure[:type]).to eq 'text'
        expect(exposure[:text_formatting]).to eq 'html'
      end
    end

    describe 'select_options' do
      let!(:field) { build('select field with options') }
      it 'returns the correct options' do
        expect(exposure[:type]).to eq 'select'
        expect(exposure[:select_options].size).to eq 2
        expect(exposure[:select_options].first.keys).to eq [:id, :name, :position]
      end
    end

  end

end
