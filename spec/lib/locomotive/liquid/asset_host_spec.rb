require 'spec_helper'

describe Locomotive::Liquid::AssetHost do

  let(:request)     { nil }
  let(:site)        { nil }
  let(:host)        { nil }
  let(:timestamp)   { nil }
  let(:asset_host)  { Locomotive::Liquid::AssetHost.new(request, site, host) }
  let(:source)      { '/sites/42/assets/1/banner.png' }

  subject { asset_host.compute(source, timestamp) }

  describe 'no host provided' do

    it { is_expected.to eq '/sites/42/assets/1/banner.png' }

  end

  describe 'with a timestamp' do

    let(:timestamp) { '42' }
    it { is_expected.to eq '/sites/42/assets/1/banner.png?42' }

    context 'the source already includes a query string' do

      let(:source) { '/sites/42/assets/1/banner.png?foo' }
      it { is_expected.to eq '/sites/42/assets/1/banner.png?foo' }

    end

  end

  describe 'the source is already a full url' do

    let(:source) { 'http://somewhere.net/sites/42/assets/1/banner.png' }
    it { is_expected.to eq 'http://somewhere.net/sites/42/assets/1/banner.png' }

    describe 'also with https' do

      let(:source) { 'https://somewhere.net/sites/42/assets/1/banner.png' }
      it { is_expected.to eq 'https://somewhere.net/sites/42/assets/1/banner.png' }

    end

  end

  describe 'the host is a string' do

    let(:host) { 'http://assets.locomotivecms.com' }
    it { is_expected.to eq 'http://assets.locomotivecms.com/sites/42/assets/1/banner.png' }

  end

  describe 'the host is a block' do

    let(:request)     { stub(ssl: true) }
    let(:site)        { stub(cdn: true) }
    let(:host) { ->(request, site) { site.cdn ? "http#{request.ssl ? 's' : ''}://assets.locomotivecms.com" : nil } }

    it { is_expected.to eq 'https://assets.locomotivecms.com/sites/42/assets/1/banner.png' }

    context 'with a different request var' do

      let(:request) { stub(ssl: false) }
      it { is_expected.to eq 'http://assets.locomotivecms.com/sites/42/assets/1/banner.png' }

    end

    context 'with a different site var' do

      let(:site) { stub(cdn: false) }
      it { is_expected.to eq '/sites/42/assets/1/banner.png' }

    end

  end

end
