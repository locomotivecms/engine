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

  end

end
