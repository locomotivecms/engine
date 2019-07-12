# encoding: utf-8

describe Locomotive::PagePolicy do

  let(:membership)  { nil }
  let(:page)        { build(:page) }
  let(:policy)      { described_class.new(membership, page) }

  describe '#permitted_attributes' do

    subject { policy.permitted_attributes }

    context 'admin' do

      let(:membership) { build(:admin) }
      it { is_expected.to eq([:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords, :cache_enabled, :cache_control, :cache_vary, :handle]) }

    end

    context 'author' do

      let(:membership) { build(:author) }
      it { is_expected.to eq([:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords]) }

    end

  end

  describe '#show?' do

    subject { policy.show? }

    let(:membership) { build(:admin) }
    it { is_expected.to eq true }

    context 'hidden page' do

      let(:page) { build(:page, display_settings: { 'hidden' => true })}

      context 'admin' do
        it { is_expected.to eq true }
      end

      context 'author' do
        let(:membership) { build(:author) }
        it { is_expected.to eq false }
      end


    end

  end

  describe "#destroy?" do

    subject { policy.destroy? }

    let(:membership) { build(:admin) }
    it { is_expected.to eq true }

    context 'index page' do

      let(:page) { build(:page, slug: 'index', depth: 0) }
      it { is_expected.to eq false }

    end

    context '404 page' do

      let(:page) { build(:page, slug: '404', depth: 0) }
      it { is_expected.to eq false }

    end

  end

end
