require 'spec_helper'

describe 'Locomotive::Middlewares::Site' do

  let(:site)        { create('existing site', domains: 'steve.me') }
  let(:url)         { 'http://example.com/locomotive/models' }
  let(:app)         { ->(env) { [200, env, "app"] } }
  let(:middleware)  { Locomotive::Middlewares::Site.new(app) }

  subject { code, env = middleware.call(env_for(url)); env['locomotive.site'] }

  describe 'no site' do

    it { is_expected.to eq(nil) }

  end

  describe 'existing site' do

    before { site }

    it { expect(subject.name).to eq('Locomotive site with existing models') }
    it { expect(subject.handle).to eq('models') }

    context 'fetching from the host' do

      let(:url) { 'http://steve.me/about' }

      it 'also returns the site'

    end

  end


end
