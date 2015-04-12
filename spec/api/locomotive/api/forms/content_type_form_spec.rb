require 'spec_helper'

describe Locomotive::API::Forms::ContentTypeForm do

  let(:attributes) { { } }
  let(:form) { described_class.new(nil, attributes) }

  describe '#entries_custom_fields=' do

    let(:fields) { [{ name: 'title', type: 'string' }, { name: 'body', type: 'string' }] }

    before do
      allow(form).to receive(:existing_content_type).and_return(content_type)
      form.entries_custom_fields = fields
    end

    subject { form.entries_custom_fields_attributes }

    context 'new content type' do

      let(:content_type) { nil }

      it { is_expected.to eq([{ name: 'title', type: 'string' }, { name: 'body', type: 'string' }]) }

    end

    context 'existing content type' do

      let(:content_type) { build(:content_type, :with_field, site: nil) }

      it { expect(subject.first[:_id]).not_to eq nil }
      it { expect(subject.last[:_id]).to eq nil }

    end

  end

  describe '#serializable_hash' do

    before { allow_any_instance_of(described_class).to receive(:existing_content_type).and_return(nil) }

    subject { form.serializable_hash }

    context 'with entries_custom_fields' do

      let(:attributes) { { entries_custom_fields: [{ name: 'title', type: 'string' }, { name: 'body', type: 'string' }] } }

      it { expect(subject[:entries_custom_fields]).to eq nil }
      it { is_expected.to eq('entries_custom_fields_attributes' => [{ 'name' => 'title', 'type' => 'string' }, { 'name' => 'body', 'type' => 'string' }]) }

    end

  end

end
