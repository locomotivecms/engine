require 'spec_helper'

describe Locomotive::API::Entities::SiteEntity do

  subject { described_class }

  %i(name locales handle domains seo_title meta_keywords
    meta_description robots_txt cache_enabled asset_host).each do |exposure|
      it { is_expected.to represent(exposure) }
    end

  context 'overrides' do
    let!(:admin)  { create(:admin) }
    let!(:site)   { admin.site }
    let(:options) { { env: { 'HTTP_HOST' => 'http://locomotive.works:8080' } } }

    subject { described_class.new(site, options) }
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

    describe 'preview_url' do
      it 'returns the url to preview the site' do
        expect(exposure[:preview_url]).to eq 'http://locomotive.works:8080/locomotive/acme/preview'
      end
    end

    describe 'sign_in_url' do
      it 'returns the url to sign in to the site' do
        expect(exposure[:sign_in_url]).to eq 'http://locomotive.works:8080/locomotive/sign_in'
      end
    end

  end

end
