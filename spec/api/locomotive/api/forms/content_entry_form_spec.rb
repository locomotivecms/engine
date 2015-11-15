require 'spec_helper'

describe Locomotive::API::Forms::ContentEntryForm do

  describe '#set_belongs_to' do

    let(:field) { double(:field, name: :foo, class_name: 'Class') }
    let(:result) { double(:result, pluck: []) }

    subject { described_class.new(nil, nil) }

    before do
      allow(Class).to receive(:by_ids_or_slugs).and_return(result)
    end

    it 'sets the dynamic attribute field' do
      subject.set_belongs_to(field, :bar)
      expect(subject.dynamic_attributes.keys).to include(:foo)
    end

  end

  describe '#set_many_to_many' do

    let(:field) { double(:field, name: 'projects', class_name: 'Class') }
    let(:result) { double(:result, pluck: [[1, :sacha], [2, :paul]]) }

    subject { described_class.new(nil, nil) }

    before do
      allow(Class).to receive(:by_ids_or_slugs).and_return(result)
    end

    it 'sets the dynamic attribute field' do
      subject.set_many_to_many(field, [:paul, :sacha])
      expect(subject.dynamic_attributes.keys).to include(:project_ids)
      expect(subject.dynamic_attributes[:project_ids]).to eq [2, 1]
    end

  end

end
