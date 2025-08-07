# encoding: utf-8

describe Locomotive::PageService do

  let!(:site)     { create(:site) }
  let(:account)   { create(:account) }
  let(:locale)    { :en }
  let(:service)   { described_class.new(site, account, locale) }

  describe '#create' do

    subject { service.create(title: 'Hello world', parent: site.pages.home.first) }

    it { expect { subject }.to change { Locomotive::Page.count }.by 1 }

    it { expect(subject.title).to eq 'Hello world' }

  end

  describe '#update' do

    let(:page) { site.pages.home.first }

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

      subject { site.pages.home.first }

      it 'sets a nice default title, the slug and the fullpath' do
        expect(subject.title_translations).to eq('en' => 'Home page', 'fr' => "Page d'accueil")
        expect(subject.slug_translations).to eq('en' => 'index', 'fr' => 'index')
        expect(subject.fullpath_translations).to eq('en' => 'index', 'fr' => 'index')
      end

    end

    context 'a sub_page' do

      subject { sub_page.reload }

      it 'sets the slug and the fullpath but not the title' do
        expect(subject.title_translations).to eq('en' => 'Subpage', 'fr' => 'Subpage [FR]')
        expect(subject.slug_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
        expect(subject.fullpath_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
        expect(subject.raw_template_translations).to eq({
          'en' => '<html><body><h1>Hello world</h1></body></html>',
          'fr' => '<html><body><h1>Hello world</h1></body></html>'
        })
      end

      context 'with sections' do

        let(:sections_content) { { banner: { settings: { title: 'Hello world' }, blocks: [] } } }
        let(:sections_dropzone_content) { [
          { type: 'gallery', settings: { title: 'My gallery of photos' }, blocks: [] },
          { type: 'testimonials', settings: { title: 'What our clients say' }, blocks: [] }
        ] }
        let!(:sub_page) { create(:sub_page, site: site, sections_content: sections_content, sections_dropzone_content: sections_dropzone_content) }

        it 'copies the sections content in the new locale' do
          expect(subject.sections_content_translations).to eq({
            'en' => { 'banner' => { 'settings' => { 'title' => 'Hello world' }, 'blocks' => [] } },
            'fr' => { 'banner' => { 'settings' => { 'title' => 'Hello world' }, 'blocks' => [] } }
          })
        end

        it 'copies the sections dropzone content in the new locale' do
          expect(subject.sections_dropzone_content_translations).to eq({
            'en' => [
              { 'type' => 'gallery', 'settings' => { 'title' => 'My gallery of photos' }, 'blocks' => [] },
              { 'type' => 'testimonials', 'settings' => { 'title' => 'What our clients say' }, 'blocks' => [] }
            ],
            'fr' => [
              { 'type' => 'gallery', 'settings' => { 'title' => 'My gallery of photos' }, 'blocks' => [] },
              { 'type' => 'testimonials', 'settings' => { 'title' => 'What our clients say' }, 'blocks' => [] }
            ]
          })
        end

      end

    end

    context 'a sub sub page' do

      subject { sub_sub_page.reload }

      it 'sets the slug and the fullpath but not the title' do
        expect(subject.title_translations).to eq('en' => 'Sub sub page', 'fr' => 'Sub sub page [FR]')
        expect(subject.slug_translations).to eq('en' => 'subpage', 'fr' => 'subpage')
        expect(subject.fullpath_translations).to eq('en' => 'subpage/subpage', 'fr' => 'subpage/subpage')
      end

    end

    context 'add a new locale and make it the default one' do

      let!(:site) { create(:site).tap { |site| site.locales = %w(fr en) } }
      let(:previous_default_locale) { 'en' }

      context 'index page' do

        subject { site.pages.home.first }

        it 'sets a nice default title, the slug and the fullpath' do
          expect(subject.title_translations).to eq('en' => 'Home page', 'fr' => "Page d'accueil")
          expect(subject.slug_translations).to eq('en' => 'index', 'fr' => 'index')
        end

      end

    end
  end

end
