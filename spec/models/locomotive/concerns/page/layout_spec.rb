require 'spec_helper'

describe Locomotive::Concerns::Page::Layout do

  let(:site)          { build(:site) }
  let(:allow_layout)  { true }
  let(:template)      { nil }
  let(:layout)        { Locomotive::Page.new(_id: 42, is_layout: true, fullpath: 'awesome-layout') }
  let(:page)          { Locomotive::Page.new(layout: layout, allow_layout: allow_layout, site: site, raw_template: template) }

  describe '#use_layout?' do

    let(:template) { 'Hello world!' }

    subject { page.use_layout? }

    it { is_expected.to eq false }

    context 'page inheriting from its parent page' do

      let(:template) { '{% extends parent %}' }

      it { is_expected.to eq true }

    end

    context 'page inheriting from another page' do

      let(:template) { '{% extends layouts/default %}' }

      it { is_expected.to eq true }

    end

  end

  describe '#find_layout' do

    subject { page.find_layout; page.layout_id }

    it { is_expected.to eq 42 }

    context 'from the raw_template' do

      let(:page) { build(:page, raw_template: ' {% extends foo/bar %}  ', site: site) }

      it 'looks for the layout based on the extends liquid tag' do
        expect(page.site.pages).to receive(:fullpath).with('foo/bar').and_return([layout])
        is_expected.to eq 42
      end

      it 'switches to the default locale' do
        allow(page.site).to receive(:is_default_locale?).and_return(false)
        expect(page.site).to receive(:with_default_locale).and_return(layout)
        is_expected.to eq 42
      end

    end

  end

  describe '#valid_allow_layout_consistency' do

    before  { page.valid? }
    subject { page.allow_layout? }

    it { is_expected.to eq true }

    context 'allow_layout was false at first' do

      let(:allow_layout) { false }
      it { is_expected.to eq false }

      context "the template doesn't include the extend liquid tag" do
        let(:template) { '{% extends parent %}' }
        it { is_expected.to eq false }
      end
    end

    context 'the template includes the extend liquid tag' do
      let(:template) { '{% extends parent %} Bla bla' }
      it { is_expected.to eq true }
    end

    context 'the template includes the extend liquid tag but also blocks' do
      let(:template) { '{% extends layouts/simple %} {% block content %}Hello world{% endblock %}' }
      it { is_expected.to eq false }
    end

  end

  describe 'allow_layout default value' do

    let(:page) { Locomotive::Page.new }

    subject { page.allow_layout }

    describe 'true for a new page' do

      it { is_expected.to eq true }

    end

    describe 'false for an existing page without the allow_layout attribute' do

      let(:page) { p = Locomotive::Page.new(site: site); p.save(validate: false); p.unset(:allow_layout); Locomotive::Page.find(p._id) }

      it { is_expected.to eq false }

    end

  end

  describe '#is_layout_or_related?' do

    let(:fullpath) { 'foo' }

    before { allow(page).to receive(:fullpath).and_return(fullpath) }

    subject { page.is_layout_or_related? }

    it { is_expected.to eq false }

    context 'page is the layouts folder' do

      let(:fullpath) { 'layouts' }
      it { is_expected.to eq true }

    end

    context 'page under layouts' do

      let(:fullpath) { 'layouts/foo' }
      it { is_expected.to eq true }

    end

  end

  describe 'use a layout' do

    subject { page.raw_template }

    context 'on create' do

      before { page.valid? }
      it { is_expected.to eq '{% extends "awesome-layout" %}' }

      context 'select the parent layout' do

        let(:page) { build(:page, layout_id: 'parent', allow_layout: allow_layout, site: site, raw_template: nil) }
        it { is_expected.to eq '{% extends parent %}' }

      end

      context 'no selected layout' do

        let(:page) { build(:page, slug: 'new-page', allow_layout: allow_layout, site: site, raw_template: nil) }
        it { is_expected.to eq '{% extends parent %}' }

        context 'the page is the home page' do

          let(:page) { build(:page, slug: 'index', site: site, layout_id: 'parent') }
          it { is_expected.to eq '{% extends parent %}' }

          it 'also adds an error to the layout attribute' do
            expect(page.valid?).to eq false
            expect(page.errors[:layout_id].first).to eq "The index page can't have its parent page as a layout"
          end

        end

      end

    end

    context 'on update' do

      let(:site)  { create(:site) }
      let!(:page) { create(:page, slug: 'sub_page', allow_layout: allow_layout, raw_template: '{% extends parent %}') }

      before { page.layout = layout; page.valid? }

      subject { page.raw_template }

      it { is_expected.to eq '{% extends "awesome-layout" %}' }

      context 'no layout allowed' do

        let(:allow_layout) { false }
        it { is_expected.to eq '{% extends parent %}' }

      end

      context 'parent selected' do

        before { page.layout_id = 'parent'; page.valid? }

        it { is_expected.to eq '{% extends parent %}' }

      end

    end

  end

end
