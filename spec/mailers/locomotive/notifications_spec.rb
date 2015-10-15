require 'spec_helper'

describe Locomotive::Notifications do

  describe 'new_content_entry' do

    let(:now)           { Time.use_zone('America/Chicago') { Time.zone.local(1982, 'sep', 16, 14, 0) } }
    let(:site)          { FactoryGirl.build(:site, domains: %w{www.acme.com}, timezone_name: 'CET') }
    let(:account)       { FactoryGirl.build(:account, email: 'bart@simpson.net') }
    let(:content_type)  { FactoryGirl.build(:content_type, site: site) }
    let(:content_entry) { FactoryGirl.build(:content_entry, content_type: content_type, site: site) }

    let(:mail) { Locomotive::Notifications.new_content_entry(account, content_entry) }

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
      Timecop.freeze(now) do
        expect(set_timezone { mail.body.encoded }).to match('a new instance has been created on 09/16/1982 21:00')
      end
    end

    it 'outputs the domain in the email body' do
      expect(mail.body.encoded).to match('<b>www.acme.com</b>')
    end

    it 'outputs the description of the content type in the email body' do
      expect(mail.body.encoded).to match('The list of my projects')
    end

    describe 'rendering based on fied type' do

      let(:content_type)  { FactoryGirl.build(:content_type, :with_text_field, site: site) }
      let(:content_entry) { content_type.entries.build(description: "hello\nworld", site: site) }

      it 'outputs the domain in the email body' do
        expect(mail.body.encoded).to match('hello<br/>world')
      end

    end

  end

  def set_timezone(&block)
    Time.use_zone(site.try(:timezone) || 'UTC', &block)
  end

end
