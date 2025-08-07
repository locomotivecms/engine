require 'spec_helper'

describe Locomotive::PagesHelper do

  include Locomotive::BaseHelper

  let(:current_site) { create(:site, locales: [:en, :fr, :es]) }
  let(:current_content_locale) { 'en' }

  describe '#display_slug?' do

    subject { display_slug?(page) }

    context 'index page' do

      let(:page) { current_site.pages.home.first  }
      it { is_expected.to eq false }

    end

    context 'a regular page' do

      let(:page) { build(:page, title: 'Hello world', slug: 'hello-world', site: current_site) }
      it { is_expected.to eq true }

    end

    context 'a templatized page' do

      let(:page) { build(:page, :templatized, site: current_site) }
      it { is_expected.to eq false }

    end

    context 'a sub page of a templatized page' do

      let(:page) { build(:page, :templatized_from_parent, site: current_site) }
      it { is_expected.to eq true }

    end

  end

end


