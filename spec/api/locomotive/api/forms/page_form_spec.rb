require 'spec_helper'

describe Locomotive::API::Forms::PageForm do

  let(:site) { create(:site) }
  let(:attributes) { { title: 'Home page' } }
  let(:form) { described_class.new(site, attributes) }

  describe '#serializable_hash' do

    subject { form.serializable_hash }

    it { is_expected.to eq('title' => 'Home page') }

    describe 'redirect' do

      let(:attributes) { { redirect_url: 'http://www.apple.com' } }
      it { is_expected.to eq('redirect' => true, 'redirect_url' => 'http://www.apple.com') }

    end

    describe 'templatized' do

      let(:attributes) { { content_type: 'articles' } }
      it { is_expected.to eq('templatized' => true, 'target_klass_slug' => 'articles') }

    end

    describe 'editable elements' do

      let(:file) { rack_asset('5k.png') }

      let(:attributes) { { editable_elements: [
        { block: 'header', slug: 'tagline', content: 'Hello world!' },
        { block: 'header', slug: 'image', content: file }] } }

      it do
        is_expected.to eq('editable_elements_attributes' => [
          { 'block' => 'header', 'slug' => 'tagline', 'content' => 'Hello world!' },
          { '_type' => 'Locomotive::EditableFile', 'block' => 'header', 'slug' => 'image', 'content' => file }
        ])
      end

    end

    describe 'parent' do

      let(:attributes) { { parent: 'index' } }
      it { expect(subject['parent_id']).not_to be nil }

    end

    describe 'template' do

      let(:attributes) { { template: 'Lorem ipsum' } }
      it { is_expected.to eq('raw_template' => 'Lorem ipsum') }

    end

  end

end
