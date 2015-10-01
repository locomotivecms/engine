require 'spec_helper'

describe Locomotive::API::Entities::SiteEntity do

  subject { described_class }

  %i(name locales handle domains seo_title meta_keywords
    meta_description robots_txt cache_enabled).each do |exposure|
      it { is_expected.to represent(exposure) }
    end

  context 'overrides' do
    let!(:admin) { create(:admin) }
    let!(:site) { admin.site }

    subject { described_class.new(site) }
    let(:exposure) { subject.serializable_hash }

    describe 'content_version' do
      it 'returns the content version (integer)' do
        expect(exposure[:content_version]).to eq 0
      end
    end

    describe 'template_version' do
      it 'returns the template version (integer)' do
        expect(exposure[:template_version]).not_to eq 0
      end
    end

    describe 'timezones' do
      it 'returns the timezone name' do
        expect(exposure[:timezone]).to eq 'UTC'
      end
    end

    describe 'memberships' do
      it 'returns an array of memberships' do
        expect(exposure[:memberships]).to be_kind_of(Array)
      end
    end
  end

end
