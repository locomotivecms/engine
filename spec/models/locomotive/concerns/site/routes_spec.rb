# encoding: utf-8

describe Locomotive::Concerns::Site::Routes do

  let(:routes) { nil }
  let(:site) { build(:site, routes: routes) }

  describe 'validation' do

    let(:routes) { [{ 'route' => '/archived/:year/:month', 'page_handle' => 'posts' }, { 'route' => '/products/:category', 'page_handle' => 'products' }] }

    it { expect(site).to be_valid }

    describe "can't be a hash" do

      let(:routes) { {} }

      it { expect { site }.to raise_error }

    end

    describe "require the route and page_handle properties" do

      let(:routes) { [{ 'route' => '/archived/:year/:month' }] }

      it 'raises an error' do
        expect(site).not_to be_valid
        expect(site.errors[:routes]).to eq(["The property '#/0' did not contain a required property of 'page_handle'"])
      end

    end

  end

end
