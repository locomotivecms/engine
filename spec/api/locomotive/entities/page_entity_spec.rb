require 'spec_helper'

describe Locomotive::API::PageEntity do

  subject { described_class }

  attributes =
    %i(
      title
      slug
      parent_id
      position
      handle
      response_type
      redirect
      redirect_url
      redirect_type
      listed
      published
      templatized
      templatized_from_parent
      is_layout
      allow_layout
      target_klass_slug
      target_klass_name
      raw_template
      seo_title
      meta_keywords
      meta_description
      fullpath
      depth
      translated_in
    )

    # Not direct methods on the model object:
    # parent_fullpath, target_entry_name, localized_fullpaths

  attributes.each do |exposure|
      it { is_expected.to represent(exposure) }
    end

  context 'overrides' do
    let(:parent_page) { create(:page, title: 'parent', slug: 'parent', raw_template: nil) }
    let(:page) { create(:page_with_editable_element, parent: parent_page) }
    subject { described_class.new(page) }
    let(:exposure) { subject.serializable_hash }

    describe 'editable_elements' do
      it 'returns the editable elements' do
        expect(exposure[:editable_elements].count).to eq 1
      end
    end

    describe 'escaped_raw_template' do
      it 'returns the template' do
        expect(exposure[:escaped_raw_template]).to eq("&lt;a&gt;a&lt;/a&gt;")
      end
    end

    describe 'target_entry_name' do
      before do
        allow(page).to receive(:target_klass_name).and_return("KlassClass")
      end

      it 'returns the target_entry_name' do
        expect(exposure[:target_entry_name]).to eq 'klass_class'
      end
    end

    describe 'localized_fullpaths' do
      context 'with a current site' do
        subject { described_class.new(page, site: page.site) }
        it 'returns the localized_fullpaths'
      end

      context 'without a current site' do
        it 'returns an empty hash' do
          expect(exposure[:localized_fullpaths]).to eq({})
        end
      end
    end

  end
end
