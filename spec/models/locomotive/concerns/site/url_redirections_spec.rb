require 'spec_helper'

describe Locomotive::Concerns::Site::UrlRedirections do

  let(:redirections) { {} }
  let(:site) { build(:site, url_redirections: redirections) }

  describe '#url_redirections=' do

    subject { site.url_redirections }

    describe 'passing nil' do

      let(:redirections) { nil }
      it { is_expected.to eq([]) }

    end

    describe 'passing an array' do

      let(:redirections) { [['/foo', '/bar'], ['/hello_world', '/hello-world']] }
      it { is_expected.to eq([['/foo', '/bar'], ['/hello_world', '/hello-world']]) }

    end

    describe 'passing a flatten array' do

      let(:redirections) { ['/foo', '/bar', '/hello_world', '/hello-world'] }
      it { is_expected.to eq([['/foo', '/bar'], ['/hello_world', '/hello-world']]) }

    end

    describe 'make sure a leading "/" character is present' do

      let(:redirections) { ['hello_world', 'hello-world'] }
      it { is_expected.to eq([['/hello_world', '/hello-world']]) }

    end

  end

end
