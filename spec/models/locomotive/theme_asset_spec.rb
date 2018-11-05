# encoding: utf-8

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
        asset.source = FixturedAsset.open('wrong.docx')
        asset.valid?
        expect(asset.valid?).to eq(false)
        expect(asset.errors[:source]).to_not be_blank
      end

      it 'is not valid if another file with the same path exists' do
        asset.source = FixturedAsset.open('5k.png')
        asset.save!

        another_asset = build(:theme_asset, site: asset.site)
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

    let(:asset) { described_class.new(site: site, folder: folder, source: FixturedAsset.open('ruby_logo.svg'), updated_at: DateTime.parse('2007/06/29 21:10:00')) }

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

  describe '#content type' do

    let(:source) { FixturedAsset.open('magic_mime_type.js') }

    subject { asset.valid?; asset.content_type }

    it "don't rely on the mime_magic_content_type method" do
      is_expected.to eq(:javascript)
    end

  end

  it_should_behave_like 'model scoped by a site' do

    let(:model)     { build(:theme_asset, source: FixturedAsset.open('5k.png')) }
    let(:attribute) { :template_version }

  end

end
