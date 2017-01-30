require 'spec_helper'

describe Locomotive::API::Resources::UrlRedirectionResource do

  include_context 'api site setup'

  let(:params) { { locale: :en } }
  let(:url_prefix) { '/locomotive/acmi/api/v3/url_redirections' }

  context 'unknown site' do
    include_context 'api header setup'

    before { header('X-Locomotive-Site-Handle', nil) }

    describe 'GET index' do
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

    before { site.url_redirections = ['/old-about', 'about-us']; site.save }

    describe 'GET index' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }
        it 'returns all the url redirections' do
          expect(parsed_response).to eq([{ 'source' => '/old-about', 'target' => '/about-us' }])
        end
      end
    end

    describe 'PUT update' do
      context 'JSON' do
        let(:redirection_params) { { source: 'old-team', target: 'our-team', hidden: true } }
        let(:put_request) { put("#{url_prefix}.json", url_redirection: redirection_params) }

        it 'adds a new url redirection' do
          put_request
          expect(site.reload.url_redirections).to eq([['/old-about', '/about-us'], ['/old-team', '/our-team']])
          expect(site.url_redirections_information['a36c81ea78b8ea6d92579d0991ec46ea']).to eq ({ 'hidden' => true })
        end

        context 'the url redirection is invalid' do

            let(:redirection_params) { { source: '', target: 'a' } }

            it 'returns 422' do
              expect(put_request.status).to eq 422
            end

          end

      end
    end

    describe 'DELETE destroy' do
      context 'JSON' do
        let(:redirection_params) { { source: '/old-about' } }
        let(:delete_request) { delete("#{url_prefix}.json", url_redirection: redirection_params) }

        it 'deletes the url redirection' do
          delete_request
          expect(site.reload.url_redirections).to eq([])
        end
      end
    end

  end

end
