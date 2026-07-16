# encoding: utf-8

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

  describe '#path' do

    subject { element.path }

    it { is_expected.to eq '' }

    context 'no block and a slug' do

      let(:attributes) { { slug: 'banner' } }
      it { is_expected.to eq 'banner' }

    end

    context 'a block and a slug' do

      let(:attributes) { { block: 'content/header', slug: 'banner' } }
      it { is_expected.to eq 'content--header--banner' }

    end

  end

  describe 'parent touch' do

    let(:site)     { create(:site) }
    let(:page)     { create(:page, site: site) }
    let!(:element) { page.editable_elements.create!(slug: 'intro', block: 'body') }

    it 'does not touch the page when saved' do
      page.set(updated_at: 1.year.ago)

      expect { element.update!(content: 'changed') }.not_to change { page.reload.updated_at }
    end

  end

end
