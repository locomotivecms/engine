require 'spec_helper'

describe Locomotive::BaseHelper do

  describe 'cache keys' do

    let(:site) { build(:site, _id: '42', updated_at: DateTime.parse('2007/06/29 00:00:00')) }
    let(:membership) { build(:membership, role: 'admin') }

    around do |ex|
      without_partial_double_verification { ex.run }
    end

    before {
      allow(helper).to receive(:current_site).and_return(site)
      allow(helper).to receive(:current_membership).and_return(membership)
      allow(helper).to receive(:locale).and_return('en')
      allow(helper).to receive(:current_content_locale).and_return('en')
    }

    describe '#cache_key_for_sidebar' do

      subject { helper.cache_key_for_sidebar }

      it { expect(subject).to eq [Locomotive::VERSION, 'en', '42', 'acme', 'admin', 'sidebar', 1183075200, 'en'] }

    end

    describe '#cache_key_for_sidebar_pages' do

      subject { helper.cache_key_for_sidebar_pages }

      it { expect(subject).to eq [Locomotive::VERSION, 'en', '42', 'acme', 'admin', 'pages', 0, 0, 'en'] }

    end

    describe '#cache_key_for_sidebar_content_types' do

      subject { helper.cache_key_for_sidebar_content_types }

      it { expect(subject).to eq [Locomotive::VERSION, 'en', '42', 'acme', 'admin', 'content_types', 0, 0] }

    end

  end

  describe '#empty_collection?' do

    let(:site)         { create(:site) }
    let(:content_type) { create(:content_type, :article, site: site) }

    it 'is true for an empty sorted criteria' do
      expect(helper.empty_collection?(content_type.entries.order_by(:_position.desc))).to eq(true)
    end

    it 'is false for a non-empty criteria' do
      content_type.entries.create!(title: 'X', _label_field_name: 'title')

      expect(helper.empty_collection?(content_type.entries.order_by(:_position.desc))).to eq(false)
    end

    it 'falls back to #empty? for a plain array' do
      expect(helper.empty_collection?([])).to eq(true)
      expect(helper.empty_collection?([1])).to eq(false)
    end

  end

end
