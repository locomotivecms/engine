require 'spec_helper'

describe Locomotive::Middlewares::ImageThumbnail do

  let(:app)         { ->(env) { [200, env, 'Hello world'] } }
  let(:middleware)  { described_class.new(app) }

  describe '.route' do

    subject { described_class.route }

    it { is_expected.to eq '/locomotive/_image_thumbnail' }

  end

  describe '#call' do

    let(:url)     { 'http://locomotive.dev/locomotive/_image_thumbnail' }
    let(:image)   { 'http://locomotive.dev/assets/banner.png' }
    let(:format)  { '300x300' }
    let(:params)  { { 'image' => image, 'format' => format } }
    let(:request) { Rack::MockRequest.new(middleware) }

    subject { request.post(url, params: params) }

    describe "pass if it doesn't match the route" do

      let(:url) { 'http://locomotive.dev/locomotive/image_thumbnail' }
      it { expect(subject.body).to eq 'Hello world' }

    end

    describe 'missing parameters' do

      let(:params) { '' }
      it { expect(subject.status).to eq 422 }

    end

    describe 'convert an url' do

      it { expect(subject.status).to eq 200 }
      it { expect(subject.body).to eq '/images/dynamic/W1siZnUiLCJodHRwOi8vbG9jb21vdGl2ZS5kZXYvYXNzZXRzL2Jhbm5lci5wbmciXSxbInAiLCJ0aHVtYiIsIjMwMHgzMDAiXV0/banner.png?sha=36df3764149782ba' }

    end

    describe 'convert a base64' do

      let(:image) { 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwACggF/yWU3jgAAAABJRU5ErkJggg==' }

      it { expect(subject.status).to eq 200 }
      it { expect(subject.body).to include("data:image/png;base64") }

      describe 'wrong format' do

        let(:format) { 'wrongsyntax' }

        it { expect(subject.status).to eq 422 }

      end

    end

  end

end
