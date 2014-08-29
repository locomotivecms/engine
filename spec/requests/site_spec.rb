require 'spec_helper'

describe 'Locomotive::Middlewares::Site' do

  let(:site)        { FactoryGirl.create('existing site') }
  let(:url)         { 'http://models.example.com' }
  let(:app)         { ->(env) { [200, env, "app"] } }
  let(:middleware)  { Locomotive::Middlewares::Site.new(app) }
  
  subject { code, env = middleware.call(env_for(url)); env['locomotive.site'] }

  describe 'no site' do 

    it { should be_nil }

  end

  describe 'existing site' do

    before { site }

    its(:name) { should eq 'Locomotive site with existing models' }
    its(:subdomain) { should eq 'models' }

  end

end
