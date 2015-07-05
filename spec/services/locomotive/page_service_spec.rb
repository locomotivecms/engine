# coding: utf-8

require 'spec_helper'

describe Locomotive::PageService do

  let!(:site)     { create(:site) }
  let(:account)   { create(:account) }
  let(:service)   { described_class.new(site, account) }

  describe '#create' do

    subject { service.create(title: 'Hello world', parent: site.pages.root.first) }

    it { expect { subject }.to change { Locomotive::Page.count }.by 1 }

    it { expect(subject.title).to eq 'Hello world' }

  end

  describe '#update' do

    let(:page) { site.pages.root.first }

    subject { service.update(page, title: 'My new home page') }

    it { expect(subject.title).to eq 'My new home page' }

  end

  describe '#localize' do

    let!(:site)         { create(:site) }
    let!(:sub_page)     { create(:sub_page, site: site) }
    let!(:sub_sub_page) { create(:sub_page, title: 'Sub sub page', site: site, parent: sub_page) }
    let(:new_locales)   { ['fr'] }
    let(:previous_default_locale) { nil }

    before { service.localize(new_locales, previous_default_locale) }

    context 'index page' do

      subject { site.pages.root.first }

      it 'sets a nice default title, the slug and the fullpath' do
        expect(subject.title_translations).to eq('en' => 'Home page', 'fr' => "Page d'accueil")
        expect(subject.slug_translations).to eq('en' => 'index', 'fr' => 'index')
        expect(subject.fullpath_translations).to eq('en' => 'index', 'fr' => 'index')
      end

    end

    context 'a sub_page' do

      subject { sub_page.reload }

      it 'sets the slug and the fullpath but not the title' do
        expect(subject.title_translations).to eq('en' => 'Subpage')
        expect(subject.slug_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
        expect(subject.fullpath_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
      end

    end

    context 'a sub sub page' do

      subject { sub_sub_page.reload }

      it 'sets the slug and the fullpath but not the title' do
        expect(subject.title_translations).to eq('en' => 'Sub sub page')
        expect(subject.slug_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
        expect(subject.fullpath_translations).to eq('en' => 'subpage/subpage', 'fr' => 'subpage/subpage')
      end

    end

    context 'add a new locale and make it the default one' do

      let!(:site) { create(:site).tap { |site| site.locales = %w(fr en) } }
      let(:previous_default_locale) { 'en' }

      context 'index page' do

        subject { site.pages.root.first }

        it 'sets a nice default title, the slug and the fullpath' do
          expect(subject.title_translations).to eq('en' => 'Home page', 'fr' => "Page d'accueil")
          expect(subject.slug_translations).to eq('en' => 'index', 'fr' => 'index')
        end

      end

    end

  end

end
