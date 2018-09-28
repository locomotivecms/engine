require 'spec_helper'

describe Locomotive::API::Resources::SnippetResource do

  include_context 'api site setup'

  let(:url_prefix) { '/locomotive/acmi/api/v3/snippets' }
  let!(:snippet) { create(:snippet) }

  context 'authenticated site' do
    include_context 'api header setup'

    describe "GET index" do
      context 'JSON' do
        before { get "#{url_prefix}.json" }

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
          expect { post("#{url_prefix}.json", snippet: snippet) }
            .to change { Locomotive::Snippet.count }.by(1)
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
          expect { put_request }.to_not change { Locomotive::Snippet.count }
        end

        it 'updates the existing snippet' do
          expect { put_request }
            .to change { Locomotive::Snippet.find(snippet.id).name }.to('new snippet')
        end

        context 'the snippet exists but we pass the slug instead of the id' do

          let(:put_request) { put("#{url_prefix}/#{snippet.slug}.json", snippet: updated_snippet) }

          it 'does not change the number of existing snippets' do
            expect { put_request }.to_not change { Locomotive::Snippet.count }
          end

          it 'updates the existing snippet' do
            expect { put_request }
              .to change { Locomotive::Snippet.find(snippet.id).name }.to('new snippet')
          end

        end

        context 'the snippet does not exist so create it' do

          let(:snippet) { instance_double('Snippet', id: 'another-snippet') }
          let(:updated_snippet) { { name: 'Another snippet', template: 'Hello world' } }

          it 'changes the number of existing snippets' do
            expect { put_request }.to change { Locomotive::Snippet.count }.by(1)
          end

          it 'creates a new snippet' do
            expect { put_request }.to change { Locomotive::Snippet.where(slug: 'another-snippet').count }.by(1)
          end

        end

      end
    end

    describe "DELETE destroy" do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}/#{snippet.id}.json") }

        it 'deletes the snippet' do
          expect { delete_request }.to change { Locomotive::Snippet.count }.by(-1)
        end

      end
    end

  end

end
