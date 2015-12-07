require 'spec_helper'

describe Locomotive::API::Resources::CurrentSiteResource do

  include_context 'api site setup'

  let(:params) { { locale: :en } }
  let(:url_prefix) { '/locomotive/acmi/api/v3/current_site' }

  context 'unknown site' do
    include_context 'api header setup'

    before { header('X-Locomotive-Site-Handle', nil) }

    describe 'GET show' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }
        it 'returns an 404 error' do
          expect(last_response).not_to be_successful
          expect(parsed_response['error']).to eq('Unknown site')
        end
      end
    end

  end

  context 'authenticated site' do
    include_context 'api header setup'

    describe 'GET show' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }
        it 'returns the current site' do
          expect(parsed_response[:name]).to eq(site.name)
          expect(parsed_response[:preview_url]).to eq('http://example.org/locomotive/acme/preview')
          expect(parsed_response[:sign_in_url]).to eq('http://example.org/locomotive/sign_in')
        end
      end
    end

    describe 'PUT update' do
      context 'JSON' do
        let(:site_params) { { name: 'emca, Inc.' } }
        let(:put_request) { put("#{url_prefix}.json", site: site_params) }

        it 'changes the site name' do
          expect{ put_request }.to change{ site.reload.name }.to('emca, Inc.')
        end

        context 'the site is invalid' do

            let(:site_params) { { name: '' } }

            it 'returns 422' do
              expect(put_request.status).to eq 422
            end

          end

      end
    end

    describe 'DELETE destroy' do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}.json") }

        it 'deletes the site' do
          expect{ delete_request }.to change { Locomotive::Site.count }.by(-1)
        end
      end
    end

  end

end
