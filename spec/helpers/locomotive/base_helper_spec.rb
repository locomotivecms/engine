require 'spec_helper'

describe Locomotive::BaseHelper do

  describe 'cache keys' do

    let(:site) { build(:site, _id: '42', updated_at: DateTime.parse('2007/06/29 00:00:00')) }

    before { allow(helper).to receive(:current_site).and_return(site) }

    describe '#cache_key_for_sidebar' do

      let(:membership) { build(:membership, role: 'admin') }

      before { allow(helper).to receive(:current_membership).and_return(membership) }

      subject { helper.cache_key_for_sidebar }

      it { expect(subject).to eq "#{Locomotive::VERSION}/site/42/sidebar/1183075200/role/admin/locale/en" }

    end

    describe '#cache_key_for_sidebar_pages' do

      subject { helper.cache_key_for_sidebar_pages }

      it { expect(subject).to eq "#{Locomotive::VERSION}/site/42/acme/sidebar/pages-0-0/locale/en" }

    end

    describe '#cache_key_for_sidebar_content_types' do

      subject { helper.cache_key_for_sidebar_content_types }

      it { expect(subject).to eq "#{Locomotive::VERSION}/site/42/acme/sidebar/content_types-0-0" }

    end

  end

end
