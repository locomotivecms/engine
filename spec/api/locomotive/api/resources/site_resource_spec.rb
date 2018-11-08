require 'spec_helper'

describe Locomotive::API::Resources::SiteResource do

  include_context 'api site setup'

  let(:locale) { :en }
  let(:params) { { locale: locale } }
  let(:url_prefix) { '/locomotive/acmi/api/v3/sites' }

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
            test_site[:locales] = [:en, :fr, :nb]
            test_site[:domains] = ['another.example.com']
          end

        end

        it 'creates a site' do
          expect { post "#{url_prefix}/", site: new_site }.to change { Locomotive::Site.count }.by(1)
        end
      end
    end

    context 'additional existing site' do
      let!(:new_site) do
        new_site = create('test site', seo_title: 'Hi')
        create(:admin, account: account, site: new_site, role: 'admin')
        new_site
      end

      describe "PUT update" do
        context 'JSON' do
          let(:new_site_params) do
            new_site.serializable_hash.merge(name: 'changed name', metafields_schema: nil, sections_content: nil, routes: nil)
          end
          let(:put_request) { put("#{url_prefix}/#{new_site.id}.json", site: new_site_params, locale: locale) }

          it 'changes the site name' do
            expect { put_request }.to change { Locomotive::Site.find(new_site.id).name }
              .to('changed name')
          end

          context 'localized params' do
            let(:locale) { 'fr' }
            let(:new_site_params) do
              new_site.serializable_hash.merge(seo_title: 'Bonjour', metafields_schema: nil, routes: nil)
            end

            it 'changes the site seo_title' do
              expect { put_request }.to change { Locomotive::Site.find(new_site.id).seo_title_translations }
                .to({ 'en' => 'Hi', 'fr' => 'Bonjour' })
            end
          end

          context 'metafields' do
            let(:new_site_params) do
              new_site.serializable_hash.merge({
                routes: nil,
                metafields_schema: [{ name: 'social', fields: [{ name: 'facebook', type: 'string' }, { name: 'twitter', type: 'string' }] }].to_json,
                metafields: { social: { facebook: 'fb.com/42', twitter: 'twitter.com/42' } }.to_json
              })
            end

            it 'changes the site metafields' do
              expect { put_request }.to change { Locomotive::Site.find(new_site.id).metafields }
                .to({ 'social' => { 'facebook' => 'fb.com/42', 'twitter' => 'twitter.com/42' } })
            end
          end

          context 'routes' do
            let(:new_site_params) do
              {
                routes: [{ route: '/archives/:year', page_handle: 'posts' }].to_json
              }
            end

            it 'changes the routes' do
              expect { put_request }.to change { Locomotive::Site.find(new_site.id).routes }
                .to([{ 'route' => '/archives/:year', 'page_handle' => 'posts' }])
            end
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
