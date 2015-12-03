require 'spec_helper'

describe Locomotive::EditableElement do

  let(:attributes)  { {} }
  let(:element)     { described_class.new(attributes) }

  describe '#label' do

    subject { element.label }

    let(:attributes) { { slug: 'first_column', label: 'Column #1' } }

    it { is_expected.to eq 'Column #1' }

    describe 'if not defined, use the slug' do

      let(:attributes) { { slug: 'first_column' } }

      it { is_expected.to eq 'First column' }

    end

  end

end
