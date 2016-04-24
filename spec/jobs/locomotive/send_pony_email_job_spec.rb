require 'spec_helper'

describe Locomotive::SendPonyEmailJob do

  let(:job) { described_class.new }

  describe '#perform' do

    let(:options) {
      {
        'to'  => 'john@doe.net',
        'attachments' => { 'foo.png' => 'SGVsbG8gd29ybGQ=\n' },
        'via' => 'smtp',
        'via_options' => {
          'address' => 'smtp.mydomain.org',
          'authentication' => 'plain'
        }
      }
    }

    subject { job.perform(options) }

    it 'sends the email' do
      expect(Pony).to receive(:mail).with({
        to: 'john@doe.net',
        attachments: { 'foo.png' => 'Hello world' },
        via: :smtp,
        via_options: { address: 'smtp.mydomain.org', authentication: :plain }
      })
      subject
    end

  end

end
