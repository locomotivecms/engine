require 'spec_helper'

describe 'Locomotive::Middlewares::Site' do

  let(:site)        { FactoryGirl.create('existing site') }
  let(:url)         { 'http://models.example.com' }
  let(:app)         { ->(env) { [200, env, "app"] } }
  let(:middleware)  { Locomotive::Middlewares::Site.new(app) }

  subject { code, env = middleware.call(env_for(url)); env['locomotive.site'] }

  describe 'no site' do

    it { is_expected.to eq(nil) }

  end

  describe 'existing site' do

    before { site }

    it { expect(subject.name).to eq('Locomotive site with existing models') }
    it { expect(subject.subdomain).to eq('models') }

  end

end
