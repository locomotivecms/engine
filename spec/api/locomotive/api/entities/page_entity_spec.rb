require 'spec_helper'

describe Locomotive::API::Entities::PageEntity do

  subject { described_class }

  attributes =
    %i(
      title
      parent_id
      position
      handle
      depth
      translated_in
      response_type
      slug
      fullpath
      redirect
      redirect_url
      redirect_type
      listed
      published
      templatized
      templatized_from_parent
      is_layout
      allow_layout
      cache_enabled
      seo_title
      meta_keywords
      meta_description
    )

  attributes.each do |exposure|
    it { is_expected.to represent(exposure) }
  end

  context 'overrides' do

    let(:site) { create(:site, locales: [:en, :fr]) }
    let(:parent_page) { create(:page, title: 'parent', slug: 'parent', site: site, raw_template: nil) }
    let(:page) { create(:page_with_editable_element, parent: parent_page) }

    subject { described_class.new(page) }

    let(:exposure) { subject.serializable_hash }

    describe 'editable_elements' do
      it 'returns the editable elements' do
        expect(exposure[:editable_elements].count).to eq 1
      end
    end

    describe 'template' do
      it 'returns the template' do
        expect(exposure[:template]).to eq '<a>a</a>'
      end
    end

    describe 'content_type' do

      let(:content_type) { instance_double('ContentType', slug: 'articles') }

      before { allow(page).to receive(:content_type).and_return(content_type) }


      it 'returns the target_entry_name' do
        expect(exposure[:content_type]).to eq 'articles'
      end
    end

    describe 'localized_fullpaths' do
      context 'with a current site' do

        let(:url_builder) { Locomotive::Steam::Services.build_simple_instance(page.site).url_builder }

        subject { described_class.new(page, site: page.site, url_builder: url_builder) }

        it 'returns the localized_fullpaths' do
          expect(exposure[:localized_fullpaths]).to eq({ 'en' => '/with_editable_element', 'fr' => '/fr/with_editable_element' })
        end
      end

      context 'without a current site' do
        it 'returns an empty hash' do
          expect(exposure[:localized_fullpaths]).to eq({})
        end
      end
    end

  end
end
