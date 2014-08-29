require 'spec_helper'

describe 'Locomotive::Middlewares::Locale' do

  let(:locales)     { ['en'] }
  let(:site)        { FactoryGirl.create('existing site', locales: locales) }
  let(:url)         { 'http://models.example.com' }
  let(:app)         { ->(env) { [200, env, "app"] } }
  let(:middleware)  { Locomotive::Middlewares::Locale.new(app) }
  
  subject { code, env = middleware.call(env_for(url, 'locomotive.site' => site)); env['locomotive.locale'] }

  describe 'not localized' do 

    it { should be_nil }

  end

  describe 'localized site' do

    let(:locales)     { ['en', 'fr', 'de'] }

    describe 'without locale in URL' do

      it { should be_nil }

    end

    describe 'with locale in URL' do

      let(:url) { 'http://models.example.com/en' }
      it { should eq 'en' }

    end


    describe 'with locale in URL (ending slash)' do

      let(:url) { 'http://models.example.com/fr/' }
      it { should eq 'fr' }

    end

    describe 'with locale in URL (long path)' do

      let(:url) { 'http://models.example.com/de/guten_morgen' }
      it { should eq 'de' }

    end


  end

end
