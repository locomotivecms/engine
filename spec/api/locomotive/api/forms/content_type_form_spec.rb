require 'spec_helper'

describe Locomotive::API::Forms::ContentTypeForm do

  let(:attributes) { { } }
  let(:form) { described_class.new(nil, attributes) }

  describe '#fields=' do

    let(:fields) { [{ name: 'title', type: 'string' }, { name: 'body', type: 'string' }] }

    before do
      allow(form).to receive(:existing_content_type).and_return(content_type)
      form.fields = fields
    end

    subject { form.entries_custom_fields_attributes }

    context 'new content type' do

      let(:content_type) { nil }

      it { is_expected.to eq([{ 'name' => 'title', 'type' => 'string' }, { 'name' => 'body', 'type' => 'string' }]) }

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

      let(:attributes) { { fields: [{ name: 'title', type: 'string' }, { name: 'body', type: 'string' }] } }

      it { expect(subject[:fields]).to eq nil }
      it { is_expected.to eq('entries_custom_fields_attributes' => [{ 'name' => 'title', 'type' => 'string' }, { 'name' => 'body', 'type' => 'string' }]) }

    end

  end

  describe '#public_submission_account_emails=' do

    let(:emails) { ['admin@locomotiveapp.org'] }

    before do
      create('admin user')
      form.public_submission_account_emails = emails
    end

    subject { form.public_submission_accounts }

    it 'uses the id of the account instead of its email' do
      expect(subject.size).to eq 1
      expect(subject.first).not_to eq 'admin@locomotiveapp.org'
    end

  end

end
