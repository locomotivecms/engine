require 'spec_helper'
module Locomotive
  describe PageEntity do
    subject { PageEntity }

    attributes =
      %i(
        title
        slug
        parent_id
        parent_fullpath
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
        target_entry_name
        raw_template
        escaped_raw_template
        seo_title
        meta_keywords
        meta_description
        fullpath
        localized_fullpaths
        depth
        template_changed
        translated_in
      )

    attributes.each do |exposure|
        it { is_expected.to represent(exposure) }
      end

    context 'overrides' do
      let(:site) { create(:site) }
      let(:page) { site.pages.root.first }
      subject { Locomotive::PageEntity.new(page) }
      let(:exposure) { subject.serializable_hash }

      describe 'editable_elements' do
        it 'returns the embedded documents'
      end
    end

  end
end
