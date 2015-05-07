require 'spec_helper'

describe Locomotive::API::Resources::PageResource do

  include_context 'api site setup'

  let(:params) { { locale: :en } }
  let(:url_prefix) { '/locomotive/acmi/api/v3/pages' }
  let(:page) { create(:page, :index, site: site) }

  context 'authenticated site' do
    include_context 'api header setup'

    describe 'GET index' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }

        it 'returns a successful response' do
          expect(last_response).to be_successful
        end

      end
    end

    describe 'GET show' do
      context 'JSON' do
        before { get "#{url_prefix}/#{page.id}.json"}

        it 'returns a successful response' do
          expect(last_response).to be_successful
        end
      end
    end

    describe 'POST create' do
      let(:new_page) do
        attributes_for('page').tap do |test_page|
          test_page[:title] = 'title'
          test_page[:slug] = 'slug'
          test_page[:parent] = site.pages.first.id
        end
      end

      context 'JSON' do
        it 'creates a page' do
          expect{ post "#{url_prefix}/", page: new_page }
            .to change{ Locomotive::Page.count }.by(1)
        end
      end
    end

    describe "PUT update" do
      context 'JSON' do
        let(:page_params) { page.serializable_hash.merge(title: 'changed title').tap { |p| p.delete('target_klass_name') } }
        let(:put_request) { put("#{url_prefix}/#{page.id}.json", page: page_params) }

        it 'changes the page title' do
          expect{ put_request }.to change{ Locomotive::Page.find(page.id).title }
            .to('changed title')
        end
      end
    end

    describe "DELETE destroy" do
      context 'JSON' do
        let!(:page_to_be_destroyed) { create(:sub_page, site: site) }
        let(:delete_request) { delete("#{url_prefix}/#{page_to_be_destroyed.id}.json") }

        it 'deletes the page' do
          expect{ delete_request }.to change { Locomotive::Page.count }.by(-1)
        end
      end
    end

  end

end
