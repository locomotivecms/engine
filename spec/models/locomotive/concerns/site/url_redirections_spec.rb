# encoding: utf-8

describe Locomotive::Concerns::Site::UrlRedirections do

  let(:redirections) { [] }
  let(:redirections_information) { {} }
  let(:site) { build(:site, url_redirections: redirections, url_redirections_information: redirections_information) }

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

      context 'the target is an external url' do

        let(:redirections) { ['hello_world', 'https://rickandmortyrule.com'] }
        it { is_expected.to eq([['/hello_world', 'https://rickandmortyrule.com']]) }

      end

    end

  end

  describe '.inc_url_redirection_counter' do

    let(:redirections) { ['/foo', '/bar'] }
    let(:url) { '/foo' }

    subject { site.reload.url_redirections_information['1effb2475fcfba4f9e8b8a1dbc8f3caf'] }

    before { site.save; Locomotive::Site.inc_url_redirection_counter(site._id, url) }

    it { is_expected.to eq('counter' => 1) }

  end

  describe '#url_redirections_with_information' do

    let(:redirections) { ['/about', '/about-us'] }
    let(:redirections_information) { { '77102f70526b1c2db0eced54632dc618' => { 'hidden' => true, 'counter' => 42 } } }

    subject { site.url_redirections_with_information }

    it { is_expected.to eq([{ 'source' => '/about', 'target' => '/about-us', 'hidden' => true, 'counter' => 42 }]) }

  end

  describe '#add_or_update_url_redirection' do

    before { site.add_or_update_url_redirection('about', '/about-us', 'hidden' => true) }

    it 'adds an url direction' do
      expect(site.url_redirections).to eq([['/about', '/about-us']])
      expect(site.url_redirections_information).to eq('77102f70526b1c2db0eced54632dc618' => { 'hidden' => true })
    end

    context 'the redirection exists' do

      let(:redirections) { ['/about', '/old/about-us'] }

      it 'updates the url direction' do
        expect(site.url_redirections).to eq([['/about', '/about-us']])
        expect(site.url_redirections_information).to eq('77102f70526b1c2db0eced54632dc618' => { 'hidden' => true })
      end

    end

  end

  describe '#remove_url_redirection' do

    let(:redirections) { ['/about', '/about-us'] }

    before { site.remove_url_redirection('about') }

    it 'removes the url direction' do
      expect(site.url_redirections).to eq([])
      expect(site.url_redirections_information).to eq({})
    end

  end

end
