require 'spec_helper'

module Locomotive
  module Resources
    describe SiteAPI do
      include_context 'api site setup'

      let(:params) { { locale: :en } }
      let(:url_prefix) { '/locomotive/acmi/api_test/v2/sites' }

      context 'authenticated site' do
        include_context 'api header setup'

        describe 'GET index' do
          context 'JSON' do
            before { get "#{url_prefix}/index.json" }
            it 'returns a successful response' do

              expect(last_response).to be_successful
            end

          end
        end

        describe 'GET show' do
          context 'JSON' do
            before { get "#{url_prefix}/#{site.id}.json"}

            it 'returns a successful response' do
              expect(last_response).to be_successful
            end
          end
        end

        describe 'POST create' do
          context 'JSON' do
            let(:new_site) do
              attributes_for('test site').tap do |test_site|
                test_site[:locales] = [:en]
                test_site[:domains] = ['another.example.com']
              end

            end

            it 'creates a site' do
              expect{ post "#{url_prefix}/", site: new_site }
                .to change{ Locomotive::Site.count }.by(1)
            end
          end
        end

        context 'additional existing site' do
          let!(:new_site) do
            new_site = create('test site')
            create(:admin, account: account, site: new_site, role: 'admin')
            new_site
          end

          describe "PUT update" do
            context 'JSON' do
              let(:new_site_params) do
                new_site.serializable_hash.merge(name: 'changed name')
              end
              let(:put_request) { put("#{url_prefix}/#{new_site.id}.json", site: new_site_params) }

              it 'changes the site name' do
                expect{ put_request }.to change{ Locomotive::Site.find(new_site.id).name }
                  .to('changed name')
              end
            end
          end

          describe "DELETE destroy" do
            context 'JSON' do
              let(:delete_request) { delete("#{url_prefix}/#{new_site.id}.json") }

              it 'deletes the site' do
                expect{ delete_request }.to change { Locomotive::Site.count }.by(-1)
              end
            end
          end
        end

      end

    end
  end
end
