require 'spec_helper'

describe Locomotive::API::Entities::EditableElementEntity do

  subject { described_class }

  attributes =
    %i(slug block hint priority content)

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do

    let(:page) { create(:page_with_editable_element) }

    subject { described_class.new(page.editable_elements.first) }

    let(:exposure) { subject.serializable_hash }

    describe '#type' do
      it { expect(exposure[:type]).to eq 'EditableText' }
    end

  end

end
