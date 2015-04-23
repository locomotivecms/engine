require 'spec_helper'

describe Locomotive::API::Resources::ContentTypeResource do

  include_context 'api site setup'

  let(:url_prefix) { '/locomotive/acmi/api/v3/content_types' }
  let!(:content_type) { create(:content_type, :with_field) }

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
        before { get "#{url_prefix}/#{content_type.id}.json" }
        it 'returns a successful response' do
          expect(last_response).to be_successful
        end
      end
    end

    describe "POST create" do
      context 'JSON' do
        let(:content_type) do
          attributes_for('tasks content type').merge({
            fields: [attributes_for('text field')]
          })
        end

        it 'creates a content type' do
          expect { post("#{url_prefix}.json", content_type: content_type) }
            .to change { Locomotive::ContentType.count }.by(1)
        end
      end
    end

    describe "PUT update" do
      context 'JSON' do
        let(:updated_content_type) do
          content_type.serializable_hash.merge(name: 'new content type')
        end

        let(:put_request) { put("#{url_prefix}/#{content_type.id}.json", content_type: updated_content_type) }

        it 'does not change the number of existing content types' do
          expect { put_request }.to_not change { Locomotive::ContentType.count }
        end

        it 'updates the existing content type' do
          expect { put_request }
            .to change { Locomotive::ContentType.find(content_type.id).name }.to('new content type')
        end

        context 'the content_type exists but we pass the slug instead of the id' do

          let(:put_request) { put("#{url_prefix}/#{content_type.slug}.json", content_type: updated_content_type) }

          it 'does not change the number of existing content types' do
            expect { put_request }.to_not change { Locomotive::ContentType.count }
          end

          it 'updates the existing content type' do
            expect { put_request }
              .to change { Locomotive::ContentType.find(content_type.id).name }.to('new content type')
          end

        end

        context 'the content_type does not exist so create it' do

          let(:content_type) { instance_double('ContentType', id: 'another-content-type') }
          let(:updated_content_type) {
            attributes_for('tasks content type', slug: 'another-content-type').merge({
              fields: [attributes_for('text field')]
            })
           }

          it 'changes the number of existing content types' do
            expect { put_request }.to change { Locomotive::ContentType.count }.by(1)
          end

          it 'creates a new content type' do
            expect { put_request }.to change { Locomotive::ContentType.where(slug: 'another_content_type').count }.by(1)
          end

        end

      end
    end

    describe "DELETE destroy" do
      context 'JSON' do
        let(:delete_request) { delete("#{url_prefix}/#{content_type.id}.json") }

        it 'deletes the content type' do
          expect { delete_request }.to change { Locomotive::ContentType.count }.by(-1)
        end

      end
    end

  end

end
