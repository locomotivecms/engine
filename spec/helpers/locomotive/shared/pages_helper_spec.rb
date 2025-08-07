require 'spec_helper'

describe Locomotive::Shared::PagesHelper do

  include Locomotive::BaseHelper

  let(:current_site)  { create(:site, locales: [:en, :fr, :es]) }
  let(:current_content_locale) { 'en' }

  describe '#localized_preview_page_paths' do

    let(:page) { current_site.pages.home.first }

    subject { localized_preview_page_paths(page, mounted_on: mounted_on) }

    context 'preview with editing (mounted_on is true)' do

      let(:mounted_on) { true }

      it 'renders the urls for each locale' do
        expect(subject['en']).to eq('/locomotive/my-site/en')
        expect(subject['es']).to eq('/locomotive/my-site/es')
        expect(subject['fr']).to eq('/locomotive/my-site/fr')
      end

    end

    context 'simple preview (mounted_on is false)' do

      let(:mounted_on) { false }

      it 'renders the urls for each locale' do
        expect(subject['en']).to eq('/en')
        expect(subject['es']).to eq('/es')
        expect(subject['fr']).to eq('/fr')
      end

    end

  end

  def preview_path(site)
    '/locomotive/my-site'
  end

end


