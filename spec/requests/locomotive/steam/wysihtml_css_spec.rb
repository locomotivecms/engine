require 'spec_helper'

describe Locomotive::Steam::Middlewares::WysihtmlCss do

  let(:url)         { 'http://example.com/' }
  let(:html)        { 'Hello world' }
  let(:page)        { nil }
  let(:app)         { ->(env) { [200, env, [html]] } }
  let(:env)         { env_for(url).tap { |e| e['steam.page'] = page } }
  let(:middleware)  { described_class.new(app) }

  subject { middleware.call(env).last.first }

  describe 'not a html page' do

    let(:page) { instance_double('SimplePage', redirect: false, response_type: 'application/xml') }

    it { is_expected.to eq('Hello world') }

  end

  describe 'html page' do

    let(:page) { instance_double('SimplePage', redirect: false, response_type: 'text/html') }

    describe 'no head tag' do

      it { is_expected.to eq('Hello world') }

    end

    describe 'head tag found' do

      let(:html) { '<html><head></head><body></body></html>' }

      it { is_expected.to match(%r(<html><head></head><body></body></html>)) }

      describe 'live editing' do

        before { env['steam.live_editing'] = true }

        it { is_expected.to match(%r(<html><head><link rel="stylesheet" type="text/css" href="/assets/locomotive/wysihtml5_editor-[^.]+.css"></head><body></body></html>)) }

      end

    end

  end

end
