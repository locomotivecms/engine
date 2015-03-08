require 'spec_helper'
module Locomotive
  describe PageEntity do
    subject { PageEntity }

    attributes =
      %i(
        title
        slug
        parent_id
        position
        handle
        response_type
        cache_strategy
        redirect
        redirect_url
        redirect_type
        listed
        published
        templatized
        is_layout
        allow_layout
        templatized_from_parent
        target_klass_slug
        target_klass_name
        raw_template
        seo_title
        meta_keywords
        meta_description
        fullpath
        depth
        template_changed
        translated_in
      )

      # Not methods on the model object:
      # parent_fullpath, target_entry_name, localized_fullpaths

    attributes.each do |exposure|
        it { is_expected.to represent(exposure) }
      end

    context 'overrides' do
      let(:site) { create(:site) }
      let(:page) { site.pages.root.first }
      subject { Locomotive::PageEntity.new(page) }
      let(:exposure) { subject.serializable_hash }

      describe 'editable_elements' do
        it 'returns the embedded documents' do
          expect(exposure[:editable_elements]).to eq []
        end
      end

      describe 'escaped_raw_template' do
        it 'returns the template'
      end

      describe 'parent_fullpath' do
        it 'returns the parent_fullpath'
      end

      describe 'target_entry_name' do
        it 'returns the target_entry_name'
      end

      describe 'localized_fullpaths' do
        it 'returns the localized_fullpaths'
      end
    end

  end
end
