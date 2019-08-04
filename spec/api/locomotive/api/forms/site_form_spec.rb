require 'spec_helper'

describe Locomotive::API::Forms::SiteForm do

  let(:attributes) { { name: 'Acme Corp', handle: 'acme', locales: 'en', domains: 'www.acme.com', seo_title: 'Hi', asset_host: 'http://asset.dev', routes: '[{"route": "archived", "page_handle": "posts"}]' } }
  let(:form) { described_class.new(attributes) }

  describe '#serializable_hash' do

    subject { form.serializable_hash }

    it { is_expected.to eq('name' => 'Acme Corp', 'handle' => 'acme', 'locales' => ['en'], 'domains' => ['www.acme.com'], 'seo_title' => 'Hi', 'asset_host' => 'http://asset.dev', 'routes' => [{ 'page_handle' => 'posts', 'route' => 'archived' }]) }

    context 'localized' do

      let(:attributes) { { seo_title: { 'fr' => 'Bonjour', 'en' => 'Hi' } } }

      it { expect(subject[:seo_title]).to eq nil }
      it { is_expected.to eq('seo_title_translations' => { 'fr' => 'Bonjour', 'en' => 'Hi' }) }

    end

  end

  describe 'timezone setter' do

    let(:attributes) { { timezone: 'Paris' } }

    subject { form.serializable_hash }

    it { is_expected.to eq({ 'timezone_name' => 'Paris' }) }

  end

end
