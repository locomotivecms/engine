require 'spec_helper'

describe Locomotive::API::Entities::ContentTypeFieldEntity do

  subject { described_class }

  attributes =
    %i(
      name
      type
      label
      hint
      default
      required
      localized
      unique
      position
      group
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

    describe 'has_many' do
      let!(:field) { build('has_many field', _parent: content_type) }
      let(:content_type) { instance_double('Posts', class_name_to_content_type: target_content_type) }
      let(:target_content_type) { instance_double('Photos', slug: 'photos') }

      it 'returns the correct options' do
        expect(exposure[:type]).to eq 'has_many'
        expect(exposure[:inverse_of]).to eq 'somefield'
        expect(exposure[:order_by]).to eq 'someotherfield'
        expect(exposure[:target]).to eq 'photos'
      end
    end

  end

end
