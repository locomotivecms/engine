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

      it 'uses the application sender regardless of the site domain' do
        expect(mail.from).to eq(['support@dummy.com'])
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
        expected_settings = {
          address: 'smtp.acme.com',
          authentication: 'plain',
          port: 587,
          enable_starttls_auto: true,
          user_name: 'john',
          password: 'easyone',
          domain: 'acme.com'
        }
        expect(mail.delivery_method).to be_a(Mail::SMTP)
        expect(mail.delivery_method.settings.slice(*expected_settings.keys)).to eq(expected_settings)
      end

      it 'uses the from parameter for the sender email' do
        expect(mail.from).to eq(['support@acme.com'])
      end

    end

    context 'the site has SMTP settings but no from address' do

      let(:metafields) { { 'mailer_settings' => { 'address' => 'smtp.acme.com', 'port' => '587', 'password' => 'topsecret' } } }

      it 'does not deliver the email' do
        expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
        expect(mail.perform_deliveries).to be(false)
      end

      it 'reports the skip without exposing delivery details' do
        line = skip_log_line
        expect(line).to be_present
        expect(line).to include('site SMTP settings without a from address')
        expect(line).to include(site._id.to_s)
        expect(line).not_to include(account.email)
        expect(line).not_to include('smtp.acme.com')
        expect(line).not_to include('topsecret')
      end

    end

    context 'the site has SMTP settings but an invalid from address' do

      let(:metafields) { { 'mailer_settings' => { 'address' => 'smtp.acme.com', 'port' => '587', 'from' => 'not-an-email' } } }

      it 'does not deliver the email' do
        expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
        expect(mail.perform_deliveries).to be(false)
      end

      it 'reports the skip without leaking the invalid address or delivery details' do
        line = skip_log_line
        expect(line).to be_present
        expect(line).to include('invalid site from address')
        expect(line).to include(site._id.to_s)
        expect(line).not_to include('not-an-email')
        expect(line).not_to include(account.email)
        expect(line).not_to include('smtp.acme.com')
      end

    end

    context 'the site has a from address but no SMTP settings' do

      let(:metafields) { { 'mailer_settings' => { 'from' => 'support@acme.com' } } }

      it 'sends through the application transport using the application sender' do
        expect(mail.from).to eq(['support@dummy.com'])
        expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

    end

    describe 'application delivery method policy' do

      before do
        allow(Locomotive.config)
          .to receive(:allow_site_notifications_via_application_delivery_method)
          .and_return(allowed)
      end

      context 'allowed and no site SMTP' do
        let(:allowed) { true }

        it 'delivers via the application delivery method' do
          expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'disallowed and no site SMTP' do
        let(:allowed) { false }

        it 'does not deliver' do
          expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it 'reports the skip to the Locomotive log with the reason, site id and no recipient' do
          line = skip_log_line
          expect(line).to be_present
          expect(line).to include('no site SMTP settings')
          expect(line).to include(site._id.to_s)
          expect(line).not_to include(account.email)
        end
      end

      context 'disallowed and the site provides only a from address' do
        let(:allowed)    { false }
        let(:metafields) { { 'mailer_settings' => { 'from' => 'support@acme.com' } } }

        it 'does not treat a from address as a delivery method' do
          expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'disallowed but the site has its own SMTP settings' do
        let(:allowed)    { false }
        let(:metafields) { { 'mailer_settings' => { 'address' => 'smtp.acme.com', 'port' => '587', 'from' => 'support@acme.com' } } }

        it 'keeps site SMTP delivery enabled' do
          expect(mail.delivery_method).to be_a(Mail::SMTP)
          expect(mail.delivery_method.settings.slice(:address, :port)).to eq(address: 'smtp.acme.com', port: 587)
          expect(mail.perform_deliveries).to be(true)
        end
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

  def skip_log_line
    logged = []
    allow(Locomotive::Common::Logger).to receive(:warn) { |message| logged << message.to_s }
    mail.deliver_now
    logged.find { |m| m.include?('[Notifications] skipped') }
  end

end
