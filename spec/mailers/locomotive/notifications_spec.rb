require 'spec_helper'

describe Locomotive::Notifications do

  describe 'new_content_entry' do

    let(:site) { FactoryGirl.build(:site, :domains => %w{www.acme.com}) }

    let(:account) { FactoryGirl.build(:account) }

    let(:content_type) { FactoryGirl.build(:content_type, :site => site) }

    let(:content_entry) { FactoryGirl.build(:content_entry, :content_type => content_type, :site => site) }

    let(:mail) { Locomotive::Notifications.new_content_entry(account, content_entry) }

    it 'renders the subject' do
      mail.subject.should == '[www.acme.com][My project] new entry'
    end

    it 'renders the receiver email' do
      mail.to.should == ['bart@simpson.net']
    end

    it 'renders the sender email' do
      mail.from.should == ['support@dummy.com']
    end

    it 'outputs the domain in the email body' do
      mail.body.encoded.should match('<b>www.acme.com</b>')
    end

    it 'outputs the description of the content type in the email body' do
      mail.body.encoded.should match('The list of my projects')
    end

  end

end