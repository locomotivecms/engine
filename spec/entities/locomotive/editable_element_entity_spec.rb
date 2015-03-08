require 'spec_helper'
module Locomotive
  describe EditableElementEntity do
    subject { EditableElementEntity }

    attributes =
      %i(slug block hint priority from_parent disabled)

    attributes.each do |exposure|
        it { is_expected.to represent(exposure) }
      end

    context 'overrides' do
      let(:page) { create(:page_with_editable_element) }
      subject { Locomotive::EditableElementEntity.new(page.editable_elements.first) }
      let(:exposure) { subject.serializable_hash }

      describe '#label' do
        it 'labelizes the slug' do
          expect(subject).to receive(:labelize)
          exposure[:label]
        end
      end

      describe '#type' do
        it 'returns the type'
      end

      describe '#block_name' do
        it 'returns the block name'
      end

    end

  end
end
