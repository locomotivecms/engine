require 'spec_helper'

describe Locomotive::API::Resources::ContentEntryResource do

  include_context 'api site setup'

  let(:content_type) { create('article content type', :with_select_field_and_options, site: site) }
  let!(:content_entry) { content_type.entries.create(title: 'Hello world', body: 'Lorem ipsum', site: site) }
  let(:url_prefix) { "/locomotive/acmi/api/v3/content_types/#{content_type.slug}/entries" }

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
        before { get "#{url_prefix}/#{content_entry._slug}.json" }
        it 'returns a successful response' do
          expect(last_response).to be_successful
        end
      end
    end

    describe "POST create" do
      context 'JSON' do
        let(:content_entry_params) do
          {
            title:          'Article #1',
            body:           'Lorem ipsum',
            featured:       true,
            picture:        Rack::Test::UploadedFile.new(FixturedAsset.path('5k.png')),
            published_on:   '2009/09/10 09:00:00',
            author_email:   'john@doe.net',
            grade:          4.2,
            duration:       420,
            tags:           ['foo', 'bar'],
            price:          '$42.0',
            category:       'Development',
            archived_at:    '2009/09/12'
          }
        end

        it 'creates a content type' do
          expect { post("#{url_prefix}.json", content_entry: content_entry_params) }
            .to change { Locomotive::ContentEntry.count }.by(1)
        end
      end
    end

    describe "PUT update" do
      context 'JSON' do
        let(:content_entry_params) { { title: 'Hello world [UPDATED]' } }

        let(:put_request) { put("#{url_prefix}/#{content_entry.id}.json", content_entry: content_entry_params) }

        it 'does not change the number of existing content types' do
          expect { put_request }.to_not change { Locomotive::ContentEntry.count }
        end

        it 'updates the existing content type' do
          expect { put_request }
            .to change { Locomotive::ContentEntry.find(content_entry.id).title }.to('Hello world [UPDATED]')
        end

        context 'the content entry exists but we pass the slug instead of the id' do

          let(:put_request) { put("#{url_prefix}/#{content_entry._slug}.json", content_entry: content_entry_params) }

          it 'does not change the number of existing content types' do
            expect { put_request }.to_not change { Locomotive::ContentEntry.count }
          end

          it 'updates the existing content type' do
            expect { put_request }
              .to change { Locomotive::ContentEntry.find(content_entry.id).title }.to('Hello world [UPDATED]')
          end

        end

        context 'the content entry does not exist so create it' do

          let(:content_entry) { instance_double('ContentEntry', id: 'another-content-entry') }
          let(:content_entry_params) { { title: 'A new test', _slug: 'another-content-entry' } }

          it 'changes the number of existing content types' do
            expect { put_request }.to change { Locomotive::ContentEntry.count }.by(1)
          end

          it 'creates a new content type' do
            expect { put_request }.to change { Locomotive::ContentEntry.where(_slug: 'another-content-entry').count }.by(1)
          end

        end

      end
    end

    describe "DELETE destroy" do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}/#{content_entry.id}.json") }

        it 'deletes the content entry' do
          expect { delete_request }.to change { Locomotive::ContentEntry.count }.by(-1)
        end

      end
    end

  end

end
