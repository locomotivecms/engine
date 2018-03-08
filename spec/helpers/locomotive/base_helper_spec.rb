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

end
