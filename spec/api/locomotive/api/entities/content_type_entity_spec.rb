require 'spec_helper'

describe Locomotive::API::Entities::ContentTypeEntity do

  subject { described_class }

  attributes =
    %i(
      name
      slug
      description
      label_field_name
      order_direction
      public_submission_enabled
      public_submission_accounts
      public_submission_title_template
      recaptcha_required
      entry_template
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do

    let!(:content_type) { create(:content_type, :with_field, :with_select_field, :grouped, :public_submission_enabled) }
    let(:exposure) { subject.serializable_hash }

    subject { described_class.new(content_type) }

    describe 'entries_custom_fields' do
      it 'returns the correct custom fields' do
        expect(exposure[:fields].size).to eq 2
      end
    end

    describe 'order_by' do
      it 'returns the correct field name' do
        expect(exposure[:order_by]).to eq 'created_at'
      end
    end

    describe 'group_by' do
      it 'returns grouped field name' do
        expect(exposure[:group_by]).to eq 'category'
      end
    end

    describe 'public_submission_account_emails' do
      it 'returns the correct emails' do
        expect(exposure[:public_submission_account_emails]).to eq ['admin@locomotiveapp.org']
      end
    end

  end

end
