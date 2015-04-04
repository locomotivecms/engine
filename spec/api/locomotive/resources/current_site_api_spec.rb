require 'spec_helper'

module Locomotive
  module Resources
    describe CurrentSiteAPI do
      include_context 'api site setup'

      let(:params) { { locale: :en } }
      let(:url_prefix) { '/locomotive/acmi/api/v3/current_site' }

      context 'authenticated site' do
        include_context 'api header setup'

        describe 'GET show' do
          context 'JSON' do
            before { get "#{url_prefix}.json" }
            it 'returns the current site' do
              expect(parsed_response[:name]).to eq(site.name)
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

          end
        end

        describe 'DELETE destroy' do
          context 'JSON' do
            let(:delete_request) { delete("#{url_prefix}.json") }

            it 'deletes the site' do
              expect{ delete_request }.to change { Site.count }.by(-1)
            end
          end
        end

      end

    end


  end
end
