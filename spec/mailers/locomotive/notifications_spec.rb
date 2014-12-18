require 'spec_helper'

describe Locomotive::Notifications do

  describe 'new_content_entry' do

    let(:now)           { Time.parse('Sep 16 1982 9:00pm') }
    let(:site)          { FactoryGirl.build(:site, domains: %w{www.acme.com}, timezone_name: 'CET') }
    let(:account)       { FactoryGirl.build(:account, email: 'bart@simpson.net') }
    let(:content_type)  { FactoryGirl.build(:content_type, site: site) }
    let(:content_entry) { FactoryGirl.build(:content_entry, content_type: content_type, site: site) }

    let(:mail) { set_timezone { Locomotive::Notifications.new_content_entry(account, content_entry) } }

    it 'renders the subject' do
      expect(mail.subject).to eq('[www.acme.com][My project] new entry')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['bart@simpson.net'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['support@dummy.com'])
    end

    it 'outputs the current time in the correct time zone' do
      Time.stubs(:now).returns(now)
      expect(mail.body.encoded).to match('a new instance has been created on 09/16/1982 21:00')
    end

    it 'outputs the domain in the email body' do
      expect(mail.body.encoded).to match('<b>www.acme.com</b>')
    end

    it 'outputs the description of the content type in the email body' do
      expect(mail.body.encoded).to match('The list of my projects')
    end

    context 'multi-site not enabled' do

      before(:each) do
        Locomotive.config.stubs(:multi_sites_or_manage_domains?).returns(false)
      end

      it 'renders the subject with the domain name coming from the ActionMailer settings' do
        ActionMailer::Base.default_url_options = { host: 'www.acme.fr' }
        expect(mail.subject).to eq('[www.acme.fr][My project] new entry')
      end

      it 'renders the subject without setting ActionMailer' do
        ActionMailer::Base.default_url_options[:host] = nil
        expect(mail.subject).to eq('[localhost][My project] new entry')
      end

    end

  end

  def set_timezone(&block)
    Time.use_zone(site.try(:timezone) || 'UTC', &block)
  end

end
