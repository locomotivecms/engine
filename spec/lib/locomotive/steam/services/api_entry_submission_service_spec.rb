require 'spec_helper'

describe Locomotive::Steam::APIEntrySubmissionService do

  let(:site)          { create(:site) }
  let(:steam_service) { instance_double('SteamContentEntryService', locale: 'en') }
  let(:params)        { {} }
  let(:request_env)   { instance_double('RequestEnv') }
  let(:request)       { instance_double('Request', ip: '127.0.0.1', user_agent: 'Rspec', referer: 'https://www.locomotivecms.com', env: request_env, params: params) }
  let(:enabled)       { true }
  let!(:content_type) { create('message content type', site: site, public_submission_enabled: enabled).reload }
  let(:service)       { described_class.new(steam_service, request) }

  describe '#submit' do

    before { expect(request_env).to receive(:[]).with('locomotive.site').and_return(site) }

    let(:attributes) { { 'name' => 'John Doe', 'message' => 'Hello' } }

    subject { service.submit(content_type.slug, attributes) }

    it { expect { subject }.to change { content_type.entries.count } }

    it 'returns a content entry' do
      expect(subject.name).to eq 'John Doe'
      expect(subject.message).to eq 'Hello'
    end

    context 'no public submission allowed' do

      let(:enabled) { false }

      it { expect(subject).to eq nil }

    end

    context 'with notified emails' do

      let(:params) { { 'notified_emails' => 'john@doe.net,jane@doe.net' } }

      it 'passes an array of emails to the content entry service' do
        expect_any_instance_of(Locomotive::ContentEntryService).to receive(:send_notifications).with(any_args, ['john@doe.net', 'jane@doe.net'])
        subject
      end

    end

  end

  describe '#to_json' do

    let(:entry) { content_type.entries.build(_id: 42, name: 'John Doe', message: 'Hello') }

    subject { service.to_json(entry) }

    it 'includes _id and fields' do
      expect(subject).to match('"_id":42')
      expect(subject).to match('"name":"John Doe"')
      expect(subject).to match('"message":"Hello"')
    end

  end

end
