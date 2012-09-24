require 'spec_helper'

describe Locomotive::Extensions::Page::Redirect do

  let(:page) { Factory.build(:page, :redirect => true, :redirect_url => 'http://www.locomotivecms.com') }

  describe 'redirect option enabled' do

    it 'is valid' do
      page.valid?
      page.errors[:redirect_url].should be_blank
    end

    it 'requires the presence of the redirect url' do
      page.redirect_url = ''
      page.valid?
      page.errors[:redirect_url].should == ["can't be blank"]
    end

  end

end