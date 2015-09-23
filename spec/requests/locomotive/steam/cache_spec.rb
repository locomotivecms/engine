require 'spec_helper'

describe 'Locomotive::Middlewares::Site' do

  let(:site_cache)  { false }
  let(:page_cache)  { false }
  let(:site)        { instance_double('CacheSite', _id: '0001', cache_enabled: site_cache, template_version: DateTime.parse('2007/06/29 00:00:00'), content_version: DateTime.parse('2009/09/10 00:00:00')) }
  let(:page)        { instance_double('CachedPage', _id: '0042', cache_enabled: page_cache) }
  let(:app)         { ->(env) { [200, env, 'app'] } }
  let(:middleware)  { Locomotive::Steam::Middlewares::Cache.new(app) }

  describe '#call' do

    let(:steam_env) { { 'steam.site' => site, 'steam.page' => page, 'steam.live_editing' => false, 'steam.path' => 'foo' } }

    subject { middleware.call(env_for('foo', steam_env)) }

    it { expect(subject.first).to eq 200 }

    context 'cache enabled' do

      before(:each) { Rails.cache.clear }

      let(:site_cache) { true }
      let(:page_cache) { true }

      it { expect(subject.first).to eq 200 }

      it 'does not go to the next middleware' do
        middleware.call(env_for('foo', steam_env)) # warm up the cache
        expect(middleware.app).not_to receive(:call)
        expect(subject.first).to eq 200
      end

    end

  end

  describe '#cache_key' do

    subject { middleware.send(:cache_key, site, 'foo/bar') }

    it { expect(subject).to eq 'site/0001/1183075200/1252540800/page/foo/bar' }

  end

  describe '#cache_enabled?' do

    subject { middleware.send(:cache_enabled?, site, page, live_editing) }

    let(:live_editing) { true }
    it { expect(subject).to eq false }

    context 'live editing off' do

      let(:live_editing) { false }
      it { expect(subject).to eq false }

      context 'cache enabled for site' do

        let(:site_cache) { true }
        it { expect(subject).to eq false }

        context 'cache enabled for page' do

          let(:page_cache) { true }
          it { expect(subject).to eq true }

        end

      end

    end

  end

end
