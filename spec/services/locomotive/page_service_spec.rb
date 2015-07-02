# coding: utf-8

require 'spec_helper'

describe Locomotive::PageService do

  let!(:site)     { create(:site) }
  let(:account)   { create(:account) }
  let(:service)   { described_class.new(site, account) }

  describe '#create' do

    subject { service.create(title: 'Hello world') }

    it { expect { subject }.to change { Locomotive::Page.count }.by 1 }

    it { expect(subject.title).to eq 'Hello world' }

  end

  describe '#update' do

    let(:page) { site.pages.root.first }

    subject { service.update(page, title: 'My new home page') }

    it { expect(subject.title).to eq 'My new home page' }

  end

  describe '#localize' do

    let!(:site) { create(:site) }
    let!(:page) { create(:sub_page, site: site )}
    let(:previous_default_locale) { nil }

    before do
      # site.update_attribute :locales, %w(en fr)
      service.localize(['fr'], previous_default_locale)
    end

    context 'index page' do

      subject { site.pages.root.first }
      it { expect(subject.attributes[:title]).to eq('en' => 'Home page') }
      it { expect(subject.attributes[:slug]).to eq('en' => 'index', 'fr' => 'index') }

    end

    context 'sub page' do

      subject { page.reload; page }
      it { expect(subject.title_translations).to eq('en' => 'Subpage') }
      it { expect(subject.attributes[:slug]).to eq('en' => 'subpage', 'fr' => 'subpage') }
      it { expect(subject.attributes[:fullpath]).to eq('en' => 'subpage', 'fr' => 'subpage') }

    end

  end

end
