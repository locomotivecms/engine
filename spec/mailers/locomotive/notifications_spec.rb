require 'spec_helper'

describe Locomotive::Notifications do

  describe 'new_content_entry' do

    let(:site) { FactoryGirl.build(:site, domains: %w{www.acme.com}) }

    let(:account) { FactoryGirl.build(:account) }

    let(:content_type) { FactoryGirl.build(:content_type, site: site) }

    let(:content_entry) { FactoryGirl.build(:content_entry, content_type: content_type, site: site) }

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

    context 'multi-site not enabled' do

      before(:each) do
        Locomotive.config.stubs(:multi_sites_or_manage_domains?).returns(false)
      end

      it 'renders the subject with the domain name coming from the ActionMailer settings' do
        ActionMailer::Base.default_url_options = { host: 'www.acme.fr' }
        mail.subject.should == '[www.acme.fr][My project] new entry'
      end

      it 'renders the subject without setting ActionMailer' do
        ActionMailer::Base.default_url_options[:host] = nil
        mail.subject.should == '[localhost][My project] new entry'
      end

    end

  end

end