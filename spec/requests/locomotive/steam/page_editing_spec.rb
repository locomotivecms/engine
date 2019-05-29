# encoding: utf-8

describe Locomotive::Steam::Middlewares::PageEditing do

  let(:url)           { 'http://example.com/' }
  let(:path)          { 'index' }
  let(:html)          { 'Hello world' }
  let(:live_editing)  { false }
  let(:locale)        { 'en' }
  let(:page)          { nil }
  let(:site)          { instance_double('Site', handle: 'Acme', locales: ['en', 'fr']) }
  let(:app)           { ->(env) { [200, env, [html]] } }
  let(:env)           { build_env }
  let(:middleware)    { described_class.new(app) }

  subject { middleware.call(env).last.first }

  describe 'not a html page' do

    let(:page) { instance_double('SimplePage', redirect: false, response_type: 'application/xml') }

    it { is_expected.to eq('Hello world') }

  end

  describe 'html page' do

    let(:page) { instance_double('SimplePage', _id: 42, redirect: false, response_type: 'text/html') }

    describe 'no head tag' do

      it { is_expected.to eq('Hello world') }

    end

    describe 'head tag found' do

      let(:html) { '<html><head><span class="locomotive-anchor"></span></head><body></body></html>' }

      it { is_expected.to eq('<html><head><span class="locomotive-anchor"></span></head><body></body></html>') }

      context 'live editing is on' do

        let(:live_editing) { true }

        it { is_expected.not_to include('<span') }
        it { is_expected.to include('<meta class="locomotive-anchor"></meta>') }
        it { is_expected.to include('<meta name="locomotive-locale" content="en" />') }
        it { is_expected.to include('<meta name="locomotive-page-id" content="42" />') }
        it { is_expected.to include('<meta name="locomotive-content-entry-id" content="" />') }
        it { is_expected.to include('<meta name="locomotive-mounted-on" content="/locomotive" />') }

      end

    end

  end

  def build_env
    env_for(url).tap do |e|
      e['steam.site']   = site
      e['steam.page']   = page
      e['steam.path']   = path
      e['steam.locale'] = locale
      e['steam.mounted_on']   = '/locomotive'
      e['steam.live_editing'] = live_editing
    end
  end

end
