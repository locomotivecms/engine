require 'spec_helper'

describe Locomotive::Concerns::Site::Locales do

  let(:site) { FactoryGirl.build(:site, locales: [:en, :fr]) }

  describe '#localized_page_fullpath' do

    context 'index page' do

      let(:page) { build_page }

      it 'returns an empty string if default locale' do
        expect(site.localized_page_fullpath(page)).to eq('')
      end

      it 'returns only the locale if another locale ' do
        expect(site.localized_page_fullpath(page, 'fr')).to eq('fr')
      end

    end

    context 'another page' do

      let(:page) { build_page('about-us', { fr: 'a-notre-sujet' }) }

      it 'returns only the fullpath if default locale' do
        expect(site.localized_page_fullpath(page)).to eq('about-us')
      end

      it 'returns the fullpath if another locale' do
        expect(site.localized_page_fullpath(page, 'fr')).to eq('fr/a-notre-sujet')
      end

    end

  end

  def build_page(slug = nil, translations = {})
    FactoryGirl.build(:page, site: site).tap do |page|
      page.slug = slug if slug
      translations.each do |locale, translation|
        ::Mongoid::Fields::I18n.with_locale(locale) do
          page.slug = translation
        end
      end
      page.send(:build_fullpath)
    end
  end

end
