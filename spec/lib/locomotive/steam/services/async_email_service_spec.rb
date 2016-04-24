require 'spec_helper'

describe Locomotive::Steam::AsyncEmailService do

  let(:page_finder)   { instance_double('PageFinder') }
  let(:liquid_parser) { instance_double('LiquidParser') }
  let(:asset_host)    { instance_double('AssetHost') }
  let(:simulation)    { false }
  let(:service)       { described_class.new(page_finder, liquid_parser, asset_host, simulation) }

  describe '#send_email!' do

    let(:options) { { to: 'john@doe.net', attachments: { 'foo.png' => 'Hello world' }, via: :smtp, via_options: { address: 'smtp.mydomain.org', authentication: :plain } } }

    subject { service.send_email!(options) }

    it 'creates a new job' do
      expect(Locomotive::SendPonyEmailJob).to receive(:perform_later).with({
        'to'  => 'john@doe.net',
        'attachments' => { 'foo.png' => "SGVsbG8gd29ybGQ=\n" },
        'via' => 'smtp',
        'via_options' => {
          'address' => 'smtp.mydomain.org',
          'authentication' => 'plain'
        }
      })
      subject
    end

    context 'no via options' do

      let(:options) { { to: 'john@doe.net' } }

      it 'creates a new job' do
        expect(Locomotive::SendPonyEmailJob).to receive(:perform_later).with({
          'to'  => 'john@doe.net'
        })
        subject
      end

    end

  end

end
