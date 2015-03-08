require 'spec_helper'

module Locomotive
  module Resources
    describe SnippetAPI do
      include Rack::Test::Methods
      let!(:site) { create(:site, domains: %w{www.acme.com}) }

      let!(:account) { create(:account) }
      let(:params) { { locale: :en } }
      let(:url_prefix) { '/locomotive/acmi/api_test/v2/snippets' }

      let!(:membership) do
        create(:admin, account: account, site: site, role: 'admin')
      end

      let!(:snippet) { create(:snippet) }

      subject { parsed_response }

      context 'authenticated site' do
        before do
          header 'X-Locomotive-Account-Token', account.api_token
          header 'X-Locomotive-Account-Email', account.email
          header 'X-Locomotive-Site-Handle', site.handle
        end

        describe "GET index" do
          context 'JSON' do
            before { get "#{url_prefix}/index.json" }

            it 'returns a successful response' do
              expect(last_response).to be_successful
            end

          end
        end

        describe "GET show" do
          context 'JSON' do
            before { get "#{url_prefix}/#{snippet.id}.json" }
            it 'returns a successful response' do
              expect(last_response).to be_successful
            end
          end
        end

        describe "POST create" do
          context 'JSON' do
            let(:snippet) { attributes_for(:snippet) }

            it 'creates a snippet' do
              expect{ post("#{url_prefix}.json", snippet: snippet) }
                .to change{ Locomotive::Snippet.count }.by(1)
            end
          end
        end

        describe "PUT update" do
          context 'JSON' do
            let(:updated_snippet) do
              snippet.serializable_hash.merge(name: 'new snippet')

            end

            let(:put_request) { put("#{url_prefix}/#{snippet.id}.json", snippet: updated_snippet) }

            it 'does not change the number of existing snippets' do
              expect{ put_request }.to_not change{ Locomotive::Snippet.count }
            end

            it 'updates the existing snippet' do
              expect{ put_request }
                .to change{ Locomotive::Snippet.find(snippet.id).name }.to('new snippet')
            end
          end
        end

        describe "DELETE destroy" do
          context 'JSON' do
            let(:delete_request) { delete("#{url_prefix}/#{snippet.id}.json") }

            it 'deletes the translation' do
              expect{ delete_request }.to change { Locomotive::Snippet.count }.by(-1)
            end

          end
        end

      end

    end
  end
end
