require 'spec_helper'

describe Locomotive::Steam::APIContentEntryService do

  let(:site)          { create(:site) }
  let(:request_env)   { instance_double('RequestEnv') }
  let(:request)       { instance_double('Request', ip: '127.0.0.1', env: request_env) }
  let!(:content_type) { create('article content type', site: site).reload }
  let(:service)       { described_class.new(nil, nil, :en, request) }

  before { expect(request_env).to receive(:[]).with('locomotive.site').and_return(site) }

  describe '#create' do

    let(:file)        { Rack::Multipart::UploadedFile.new(FixturedAsset.path('5k.png'), 'image/png') }
    let(:attributes)  { { title: 'Hello world', body: 'Lorem ipsum...', picture: file } }

    subject { service.create(content_type.slug, attributes, true) }

    it 'persists the content entry' do
      expect { subject }.to change(Locomotive::ContentEntry, :count).by(1)
      expect(subject['picture']['url']).to eq '5k.png'
    end

    context 'marshalled picture' do

      let(:file) {
        {
          'content_type' => 'image/png',
          'original_filename' => '5k.png',
          'filename' => '5k.png',
          'tempfile' => FixturedAsset.path('5k.png')
        }
      }

      it 'persists the content entry' do
        expect(subject['picture']['url']).to eq '5k.png'
      end

    end

  end

end
