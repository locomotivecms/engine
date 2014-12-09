require 'spec_helper'

describe 'Locomotive::Middlewares::LocaleRedirection' do

  let(:prefixed)    { false }
  let(:site)        { FactoryGirl.create('existing site', prefix_default_locale: prefixed, locales: %w(de fr)) }
  let(:url)         { 'http://models.example.com' }
  let(:app)         { ->(env) { [200, env, "app"] } }
  let(:middleware)  { Locomotive::Middlewares::LocaleRedirection.new(app) }
  let(:locale)      { 'de' }

  subject do
    code, env = middleware.call(env_for(url, 'locomotive.site' => site, 'locomotive.locale' => locale))
    [code, env['Location']]
  end

  describe 'not prefixed by locale' do

    describe 'strip default locale from root path' do
      let(:url) { 'http://models.example.com/de' }
      it { should eq [301, 'http://models.example.com'] }
    end

    describe 'strip default locale' do
      let(:url) { 'http://models.example.com/de/hello' }
      it { should eq [301, 'http://models.example.com/hello'] }
    end

    describe 'strip default locale from root path with query' do
      let(:url) { 'http://models.example.com/de?this=is_a_param' }
      it { should eq [301, 'http://models.example.com?this=is_a_param'] }
    end

    describe 'strip default locale from path with query' do
      let(:url) { 'http://models.example.com/de/hello?this=is_a_param' }
      it { should eq [301, 'http://models.example.com/hello?this=is_a_param'] }
    end

    describe 'dont strip a non-default locale' do
      let(:locale)  { 'fr' }
      let(:url)     { 'http://models.example.com/fr/hello' }
      it { should eq [200, nil] }
    end

    describe 'dont redirect URL without locale' do
      let(:locale)  { nil }
      let(:url)     { 'http://models.example.com/hello' }
      it { should eq [200, nil] }
    end

  end

  describe 'prefixed by locale' do

    let(:prefixed)    { true }

    describe 'without locale' do

      let(:locale)      { nil }

      describe 'add default locale to root path' do
        let(:url) { 'http://models.example.com/' }
        it { should eq [301, 'http://models.example.com/de'] }
      end

      describe 'add default locale to long path' do
        let(:url) { 'http://models.example.com/hello/world' }
        it { should eq [301, 'http://models.example.com/de/hello/world'] }
      end

      describe 'add default locale to url with path and query' do
        let(:url) { 'http://models.example.com/hello/world?this=is_me' }
        it { should eq [301, 'http://models.example.com/de/hello/world?this=is_me'] }
      end

      describe 'dont add default locale to backoffice' do
        let(:url) { 'http://models.example.com/locomotive' }
        it { should eq [200, nil] }
      end

      describe 'dont add default locale to assets' do
        let(:url) { 'http://models.example.com/assets/locomotive.css?body=1' }
        it { should eq [200, nil] }
      end

    end

    describe 'with locale' do

     describe 'dont add default locale if already present' do
        let(:locale) { 'de' }
        let(:url)    { 'http://models.example.com/de/hello/world' }
        it { should eq [200, nil] }
     end

     describe 'dont add default locale to localized path' do
        let(:locale) { 'fr' }
        let(:url)    { 'http://models.example.com/fr/hello/world' }
        it { should eq [200, nil] }
     end

    end

  end

end
