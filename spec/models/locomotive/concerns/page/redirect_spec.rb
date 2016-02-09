require 'spec_helper'

describe Locomotive::Concerns::Page::Redirect do

  let(:page) { FactoryGirl.build(:page, redirect: true, redirect_url: 'http://www.locomotivecms.com') }

  describe 'redirect option enabled' do

    it 'is valid' do
      page.valid?
      expect(page.errors[:redirect_url]).to be_blank
    end

    it 'requires the presence of the redirect url' do
      page.redirect_url = ''
      page.valid?
      expect(page.errors[:redirect_url]).to eq(["can't be blank"])
    end

    it 'requires the presence of the redirect type' do
      page.redirect_type = ''
      page.valid?
      expect(page.errors[:redirect_type]).to eq(["can't be blank"])
    end

    it 'requires valid URLs' do
      page.redirect_url = 'http:/foo.fr'
      page.valid?
      expect(page.errors[:redirect_url]).to eq(['is invalid'])

      page.redirect_url = 'httpss://foo.fr'
      page.valid?
      expect(page.errors[:redirect_url]).to eq(['is invalid'])
    end

    it 'allows absolute urls' do
      page.redirect_url = '/'
      page.valid?
      expect(page.errors[:redirect_url]).to be_blank
      page.redirect_url = '/foo/bar'
      page.valid?
      expect(page.errors[:redirect_url]).to be_blank
    end

    it 'also allows mailto as a valid URL' do
      page.redirect_url = 'mailto:foo@foo.fr'
      page.valid?
      expect(page.errors[:redirect_url]).to be_blank
    end

  end

end
