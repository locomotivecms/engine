require 'spec_helper'

describe Locomotive::TranslationAPI do
  let(:site) { create(:site, domains: %w{www.acme.com}) }
  let!(:translation) { create(:translation, site: site) }
  let!(:unscoped_translation) { create(:translation)}
  subject { parsed_response }

  context 'no authenticated site' do
    describe "GET /locomotive/api_test/v2/translation/index" do
      context 'JSON' do
        it 'returns an empty array' do
          get '/locomotive/api_test/v2/translation/index.json'
          expect(subject.count).to eq 0
        end
      end
    end
  end

  context 'authenticated site' do
    describe "GET /locomotive/api_test/v2/translation/index" do
      context 'JSON' do
        it 'returns one translation' do
          get '/locomotive/api_test/v2/translation/index.json'
          expect(subject.count).to eq 1
        end
      end
    end
  end

end
