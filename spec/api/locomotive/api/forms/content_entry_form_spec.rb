require 'spec_helper'

describe Locomotive::API::Forms::ContentEntryForm do
  describe '#set_belongs_to' do
    subject { described_class.new(nil, nil ) }
    let(:field) { double(:field, name: :foo, class_name: 'Class') }
    let(:result) { double(:result, pluck: []) }

    before do
      allow(Class).to receive(:by_ids_or_slugs).and_return(result)
    end

    it 'sets the dynamic attribute field' do
      subject.set_belongs_to(field, :bar)
      expect(subject.dynamic_attributes.keys).to include(:foo)
    end

  end

end
