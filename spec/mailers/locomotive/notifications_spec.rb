# encoding: utf-8

describe Locomotive::Notifications do

  describe 'new_content_entry' do

    let(:now)           { Time.use_zone('America/Chicago') { Time.zone.local(1982, 'sep', 16, 14, 0) } }
    let(:domains)       { [] }
    let(:metafields)    { {} }
    let(:site)          { build(:site, :with_custom_smtp_settings, name: 'Acme', domains: domains, timezone_name: 'Paris', metafields: metafields) }
    let(:account)       { build(:account, email: 'bart@simpson.net') }
    let(:content_type)  { build(:content_type, site: site) }
    let(:content_entry) { build(:content_entry, content_type: content_type, site: site) }

    let(:mail) { Locomotive::Notifications.new_content_entry(site, account, content_entry) }

    it 'renders the subject' do
      expect(mail.subject).to eq('[localhost][My project] new entry')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['bart@simpson.net'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['support@dummy.com'])
    end

    it 'outputs the current time in the correct time zone' do
      travel_to(now) do
        expect(set_timezone { mail.body.encoded }).to match('a new instance has been created on 09/16/1982 21:00')
      end
    end

    it 'outputs the domain in the email body' do
      expect(mail.body.encoded).to match('<b>localhost</b>')
    end

    it 'outputs the description of the content type in the email body' do
      expect(mail.body.encoded).to match('The list of my projects')
    end

    context 'the site has a main domain' do

      let(:domains) { %w{www.acme.com} }

      it 'renders the subject' do
        expect(mail.subject).to eq('[www.acme.com][My project] new entry')
      end

      it 'outputs the domain in the email body' do
        expect(mail.body.encoded).to match('<b>www.acme.com</b>')
      end

      it 'uses the top level domain name for the sender email' do
        expect(mail.from).to eq(['noreply@acme.com'])
      end

      it 'uses the default SMTP settings to deliver emails' do
        expect(mail.delivery_method.settings).to eq({})
      end

    end

    context 'the site has metafields describing a SMTP server' do

      let(:metafields) { { 'mailer_settings' => {
        'address' => 'smtp.acme.com',
        'authentication' =>  'plain',
        'port' => '587',
        'enable_starttls_auto' => '1',
        'user_name' => 'john',
        'password' => 'easyone',
        'domain' => 'acme.com',
        'from' => 'support@acme.com'
      } } }

      it 'uses the site SMTP settings to deliver emails' do
        expect(mail.delivery_method.settings).to eq({
          address: 'smtp.acme.com',
          authentication: 'plain',
          port: 587,
          enable_starttls_auto: true,
          user_name: 'john',
          password: 'easyone',
          domain: 'acme.com'
        })
      end

      it 'uses the from parameter for the sender email' do
        expect(mail.from).to eq(['support@acme.com'])
      end

    end

    describe 'rendering based on field types' do

      describe 'text type' do

        let(:content_type)  { build(:content_type, :with_text_field, site: site) }
        let(:content_entry) { content_type.entries.build(description: "hello\nworld", site: site) }

        it 'outputs the formatted value of the text field' do
          expect(mail.body.encoded).to match('hello<br/>world')
        end

      end

      describe 'date time type' do

        let(:content_type)  { build(:content_type, :with_date_time_field, site: site) }
        let(:content_entry) { content_type.entries.build(time: DateTime.parse('2015/09/26 10:45pm CDT'), site: site) }

        it 'outputs the formatted value of the date time field' do
          expect(mail.body.encoded).to match('09/27/2015 05:45')
        end

      end

    end

    describe 'attaching uploaded files' do

      let(:content_type)  { build('message content type', site: site, public_submission_email_attachments: enabled) }
      let(:content_entry) { content_type.entries.build(name: 'Jack', message: 'Hello world', resume: FixturedAsset.open('5k.png'), site: site) }

      context 'the option is off' do

        let(:enabled) { false }

        it "doesn't attach the file to the email" do
          expect(mail.attachments).to eq []
        end

      end

      context 'the option is on' do

        let(:enabled) { true }

        it "attaches the file to the email" do
          expect(mail.attachments.size).to eq 1
        end

      end

    end

    context 'custom title' do

      before do
        content_type.public_submission_title_template = "{{ site.name }} - you have a message"
      end

      it 'renders the subject' do
        expect(mail.subject).to eq 'Acme - you have a message'
      end

    end

  end

  def set_timezone(&block)
    Time.use_zone(site.try(:timezone) || 'UTC', &block)
  end

end
