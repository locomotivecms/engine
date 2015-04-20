require 'spec_helper'

describe Locomotive::API::Entities::ContentTypeEntity do

  subject { described_class }

  attributes =
    %i(
      name
      slug
      description
      label_field_name
      order_by
      order_direction
      group_by_field_id
      public_submission_enabled
      raw_item_template
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do
    let!(:content_type) { create(:content_type) }
    let(:exposure) { subject.serializable_hash }
    subject { described_class.new(content_type) }

    describe 'entries_custom_fields' do
      it 'returns the correct custom fields'
    end

    describe 'order_by_field_name' do
      it 'returns the correct field names'
    end

    describe 'group_by_field_name' do
      it 'returns grouped field names'
    end

    describe 'public_submission_account_emails' do
      it 'returns the correct emails'
    end

  end

end
