require 'spec_helper'

describe 'Locomotive::Middlewares::Site' do

  let(:site)        { create('existing site', domains: ['steve.me']) }
  let(:url)         { 'http://example.com/locomotive/models' }
  let(:app)         { ->(env) { [200, env, 'app'] } }
  let(:middleware)  { Locomotive::Middlewares::Site.new(app) }

  subject { code, env = middleware.call(env_for(url)); env['locomotive.site'] }

  describe 'no site' do

    it { is_expected.to eq(nil) }

  end

  describe 'requesting the back-office assets' do

    before { site }
    before { allow(middleware).to receive(:default_host).and_return('steve.me') }

    let(:url) { 'http://steve.me/assets/foo.png' }
    it { is_expected.to eq(nil) }

    context 'localhost' do

      let(:url) { 'http://localhost/assets/foo.png' }
      it { is_expected.to eq(nil) }

    end

    context '0.0.0.0' do

      let(:url) { 'http://0.0.0.0/assets/foo.png' }
      it { is_expected.to eq(nil) }

    end

  end

  describe 'the requested site is also the default host' do

    before { site }
    before { allow(middleware).to receive(:default_host).and_return('steve.me') }

    context 'home page' do

      let(:url) { 'http://steve.me' }
      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

    context 'about page' do

      let(:url) { 'http://steve.me/about' }
      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

    context 'locomotive app section' do

      let(:url) { 'http://steve.me/locomotive/sites' }
      it { is_expected.to eq(nil) }

    end

  end

  describe 'existing site' do

    before { site }

    it { expect(subject.name).to eq('Locomotive site with existing models') }
    it { expect(subject.handle).to eq('models') }

    context 'fetching from the host' do

      let(:url) { 'http://steve.me/about' }

      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

  end


end
