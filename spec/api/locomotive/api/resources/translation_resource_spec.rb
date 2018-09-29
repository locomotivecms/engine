require 'spec_helper'

describe Locomotive::API::Resources::TranslationResource do

  include_context 'api site setup'

  let!(:translation) { travel_to(Time.zone.local(2015, 4, 1, 12, 0, 0)) { create(:translation, site: site) } }
  let(:params) { { locale: :en } }
  let(:url_prefix) { '/locomotive/acmi/api/v3/translations' }

  let(:translation_hash) do
    values = translation.values.stringify_keys
    { 'key' => translation.key, 'values' => values, 'created_at' => '2015-04-01T12:00:00Z', 'updated_at' => '2015-04-01T12:00:00Z' }
  end

  context 'no authenticated site' do
    describe "GET /locomotive/acme/api/v3/translations.json" do
      context 'JSON' do
        it 'returns unauthorized message' do
          get "#{url_prefix}.json"
          expect(subject).to eq({ 'error' => 'Unauthorized' })
        end

        it 'returns unauthorized response' do
          get "#{url_prefix}.json"
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  context 'authenticated site' do
    include_context 'api header setup'

    describe "GET index" do
      context 'JSON' do

        before { get "#{url_prefix}.json" }

        it 'returns a successful response' do
          expect(last_response).to be_successful
        end

        it 'returns the translation in an array' do
          expect(subject.first.delete('_id')).to match /^[a-z0-9]+$/
          expect(subject).to eq [translation_hash]
        end
      end
    end

    describe "GET show" do
      context 'JSON' do
        before { get "#{url_prefix}/#{translation.id}.json" }
        it 'returns a successful response' do
          expect(last_response).to be_successful
        end
      end
    end

    describe "POST create" do
      context 'JSON' do
        let(:json) { { key: :site, values: { one: :uno } } }

        it 'creates a translation on the current site' do
          expect{ post("#{url_prefix}.json", translation: json) }
            .to change{ Locomotive::Translation.count }.by(1)
        end
      end
    end

    describe "PUT update" do
      context 'JSON' do
        let(:json) { { key: translation.key, values: { one: :uno } } }
        let(:put_request) { put("#{url_prefix}/#{translation.id}.json", translation: json) }

        it 'does not change the number of existing translations' do
          expect{ put_request }.to_not change{ Locomotive::Translation.count }
        end

        it 'updates the existing translation' do
          expect{ put_request }
            .to change{ Locomotive::Translation.find(translation.id).values }
            .to({ 'one' => 'uno' })
        end
      end
    end

    describe "DELETE destroy" do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}/#{translation.id}.json") }

        it 'deletes the translation' do
          expect{ delete_request }.to change { Locomotive::Translation.count }.by(-1)
        end

        it 'returns the deleted translation' do
          delete_request
          expect(subject.delete('_id')).to match /^[a-z0-9]+$/
          expect(subject).to eq(translation_hash)
        end
      end
    end

  end

end
