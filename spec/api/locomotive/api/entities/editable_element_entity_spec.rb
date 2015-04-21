require 'spec_helper'

describe Locomotive::API::Entities::EditableElementEntity do

  subject { described_class }

  attributes =
    %i(slug block hint priority from_parent disabled)

  attributes.each do |exposure|
      it { is_expected.to represent(exposure) }
    end

  context 'overrides' do
    let(:page) { create(:page_with_editable_element) }
    subject { described_class.new(page.editable_elements.first) }
    let(:exposure) { subject.serializable_hash }

    describe '#label' do
      it 'labelizes the slug' do
        expect(exposure[:label]).to eq 'editable-element'
      end
    end

    describe '#block_name' do
      context 'with block name set' do
        subject do
          editable_element = page.editable_elements.first
          editable_element.update_attributes(block: 'not-main')
          editable_element = described_class.new(page.editable_elements.first)
        end

        it 'returns the block name' do
          expect(subject.object.block).to eq 'not-main'
        end
      end

      context 'without a set block name' do
        it 'returns the default block name' do
          expect(exposure[:block_name]).to eq 'main'
        end
      end
    end

  end

end
