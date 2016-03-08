require 'spec_helper'

describe Locomotive::PagePolicy do

  let(:membership)  { nil }
  let(:page)        { build(:page) }
  let(:policy)      { described_class.new(membership, page) }

  describe '#permitted_attributes' do

    subject { policy.permitted_attributes }

    context 'admin' do

      let(:membership) { build(:admin) }
      it { is_expected.to eq([:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords, :cache_enabled, :handle]) }

    end

    context 'author' do

      let(:membership) { build(:author) }
      it { is_expected.to eq([:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords, :cache_enabled]) }

    end

  end

end
