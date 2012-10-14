require 'spec_helper'

describe Locomotive::Extensions::Site::Locales do

  let(:site) { Factory.build(:site, :locales => [:en, :fr]) }

  describe '#localized_page_fullpath' do

    context 'index page' do

      let(:page) { build_page }

      it 'returns an empty string if default locale' do
        site.localized_page_fullpath(page).should == ''
      end

      it 'returns only the locale if another locale ' do
        site.localized_page_fullpath(page, 'fr').should == 'fr'
      end

    end

    context 'another page' do

      let(:page) { build_page('about-us', { :fr => 'a-notre-sujet' }) }

      it 'returns only the fullpath if default locale' do
        site.localized_page_fullpath(page).should == 'about-us'
      end

      it 'returns the fullpath if another locale' do
        site.localized_page_fullpath(page, 'fr').should == 'fr/a-notre-sujet'
      end

    end

  end

  def build_page(slug = nil, translations = {})
    Factory.build(:page).tap do |page|
      page.slug = slug if slug
      page.send(:build_fullpath)
      translations.each do |locale, translation|
        ::Mongoid::Fields::I18n.with_locale(locale) do
          page.slug = translation
          page.send(:build_fullpath)
        end
      end
    end
  end

end
