# coding: utf-8

require 'spec_helper'

describe Locomotive::ThemeAsset do

  let(:site)    { build(:site, domains: %w{www.acme.com}) }
  let(:source)  { nil }
  let(:asset)   { build(:theme_asset, site: site, source: source, updated_at: DateTime.parse('2007/06/29 21:10:00')) }

  describe 'attaching a file' do

    describe 'file is a picture' do

      it 'processes picture' do
        asset.source = FixturedAsset.open('5k.png')
        expect(asset.source.file.content_type).to_not eq(nil)
        expect(asset.image?).to eq(true)
      end

      it 'gets width and height from the image' do
        asset.source = FixturedAsset.open('5k.png')
        expect(asset.width).to eq(32)
        expect(asset.height).to eq(32)
      end

    end

    describe 'local path and folder' do

      it 'sets the local path based on the content type' do
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        expect(asset.local_path).to eq('images/5k.png')
      end

      it 'sets the local path based on the folder' do
        asset.folder = 'trash'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        expect(asset.local_path).to eq('images/trash/5k.png')
      end

      it 'does not only use the folder to build the local path' do
        asset.folder = 'images42'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        expect(asset.local_path).to eq('images/images42/5k.png')
      end

      it 'sets sanitize the local path' do
        asset.folder = '/images/à la poubelle'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        expect(asset.local_path).to eq('images/a_la_poubelle/5k.png')
      end

      it 'keeps the original name for a retina image' do
        asset.source = FixturedAsset.open('5k@2x.png')
        asset.save
        expect(asset.local_path).to eq('images/5k@2x.png')
      end

    end

    describe '#validation' do

      it 'does not accept text file' do
        asset.source = FixturedAsset.open('wrong.txt')
        expect(asset.valid?).to eq(false)
        expect(asset.errors[:source]).to_not be_blank
      end

      it 'is not valid if another file with the same path exists' do
        asset.source = FixturedAsset.open('5k.png')
        asset.save!

        another_asset = FactoryGirl.build(:theme_asset, site: asset.site)
        another_asset.source = FixturedAsset.open('5k.png')
        expect(another_asset.valid?).to eq(false)
        expect(another_asset.errors[:local_path]).to_not be_blank
      end

    end

    it 'processes stylesheet' do
      asset.source = FixturedAsset.open('main.css')
      expect(asset.source.file.content_type).to_not eq(nil)
      expect(asset.stylesheet?).to eq(true)
    end

    it 'processes javascript' do
      asset.source = FixturedAsset.open('application.js')
      expect(asset.source.file.content_type).to_not eq(nil)
      expect(asset.javascript?).to eq(true)
    end

    it 'gets size' do
      asset.source = FixturedAsset.open('main.css')
      expect(asset.size).to eq(25)
    end

    it 'sets the checksum when it is saved' do
      asset.source = FixturedAsset.open('5k.png')
      asset.save
      expect(asset.checksum).to eq('f1af16493e6cba9eaed7bc8a8643246e')
    end

  end

  describe 'SVG assets' do

    let(:asset) { build(:theme_asset, site: site, folder: folder, source: FixturedAsset.open('ruby_logo.svg'), updated_at: DateTime.parse('2007/06/29 21:10:00')) }

    before { asset.save }

    describe 'uploaded in the fonts folder' do

      let(:folder) { 'fonts' }

      it 'is considered as a font' do
        expect(asset.content_type).to eq :font
      end

    end


    describe 'uploaded in the images folder' do

      let(:folder) { 'images' }

      it 'is considered as an image' do
        expect(asset.content_type).to eq :image
      end

    end

  end

  describe 'creating from plain text' do

    let(:asset) { FactoryGirl.build(:theme_asset,
        site: site,
        plain_text_name: 'test',
        plain_text: 'Lorem ipsum',
        performing_plain_text: true) }

    it 'handles stylesheet' do
      asset.plain_text_type = 'stylesheet'
      expect(asset.valid?).to eq(true)
      expect(asset.stylesheet?).to eq(true)
      expect(asset.source).to_not eq(nil)
    end

    it 'handles javascript' do
      asset.plain_text_type = 'javascript'
      expect(asset.valid?).to eq(true)
      expect(asset.javascript?).to eq(true)
      expect(asset.source).to_not eq(nil)
    end

  end

  describe '.escape_shortcut_urls' do

    before(:each) do
      expect(site.theme_assets).to receive(:where).with(local_path: 'images/banner.png').and_return([image])
    end

    let(:image) { instance_double('ThemeAsset', source: OpenStruct.new(url: 'http://engine.dev/images/banner.png')) }

    subject { asset.send(:escape_shortcut_urls, text) }

    context 'simple url' do

      let(:text) { "background: url(/images/banner.png) no-repeat 0 0" }
      it { is_expected.to eq "background: url(http://engine.dev/images/banner.png?1183151400) no-repeat 0 0" }

    end

    context 'url with quotes' do

      let(:text) { "background: url(\"/images/banner.png\") no-repeat 0 0" }
      it { is_expected.to eq "background: url(\"http://engine.dev/images/banner.png?1183151400\") no-repeat 0 0" }

    end

    context 'url with quotes and timestamps' do

      let(:text) { "background: url(\"/images/banner.png?123456\") no-repeat 0 0" }
      it { is_expected.to eq "background: url(\"http://engine.dev/images/banner.png?1183151400\") no-repeat 0 0" }

    end

  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { build(:theme_asset, source: FixturedAsset.open('5k.png')) }
    let(:attribute) { :template_version }

  end

end
