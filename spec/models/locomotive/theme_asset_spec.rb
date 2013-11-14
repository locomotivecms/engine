# coding: utf-8

require 'spec_helper'

describe Locomotive::ThemeAsset do

  let(:site) { FactoryGirl.build(:site, domains: %w{www.acme.com}) }

  let(:asset) { FactoryGirl.build(:theme_asset, site: site) }

  describe 'attaching a file' do

    describe 'file is a picture' do

      it 'should process picture' do
        asset.source = FixturedAsset.open('5k.png')
        asset.source.file.content_type.should_not be_nil
        asset.image?.should be_true
      end

      it 'should get width and height from the image' do
        asset.source = FixturedAsset.open('5k.png')
        asset.width.should == 32
        asset.height.should == 32
      end

    end

    describe 'local path and folder' do

      it 'should set the local path based on the content type' do
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        asset.local_path.should == 'images/5k.png'
      end

      it 'should set the local path based on the folder' do
        asset.folder = 'trash'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        asset.local_path.should == 'images/trash/5k.png'
      end

      it 'should not only use the folder to build the local path' do
        asset.folder = 'images42'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        asset.local_path.should == 'images/images42/5k.png'
      end

      it 'should set sanitize the local path' do
        asset.folder = '/images/à la poubelle'
        asset.source = FixturedAsset.open('5k.png')
        asset.save
        asset.local_path.should == 'images/a_la_poubelle/5k.png'
      end

      it 'should keep the original name for a retina image' do
        asset.source = FixturedAsset.open('5k@2x.png')
        asset.save
        asset.local_path.should == 'images/5k@2x.png'
      end

    end

    describe '#validation' do

      it 'does not accept text file' do
        asset.source = FixturedAsset.open('wrong.txt')
        asset.valid?.should be_false
        asset.errors[:source].should_not be_blank
      end

      it 'is not valid if another file with the same path exists' do
        asset.source = FixturedAsset.open('5k.png')
        asset.save!

        another_asset = FactoryGirl.build(:theme_asset, site: asset.site)
        another_asset.source = FixturedAsset.open('5k.png')
        another_asset.valid?.should be_false
        another_asset.errors[:local_path].should_not be_blank
      end

    end

    it 'should process stylesheet' do
      asset.source = FixturedAsset.open('main.css')
      asset.source.file.content_type.should_not be_nil
      asset.stylesheet?.should be_true
    end

    it 'should process javascript' do
      asset.source = FixturedAsset.open('application.js')
      asset.source.file.content_type.should_not be_nil
      asset.javascript?.should be_true
    end

    it 'should get size' do
      asset.source = FixturedAsset.open('main.css')
      asset.size.should == 25
    end

    it 'sets the checksum when it is saved' do
      asset.source = FixturedAsset.open('5k.png')
      asset.save
      asset.checksum.should == 'f1af16493e6cba9eaed7bc8a8643246e'
    end

  end

  describe 'creating from plain text' do

    let(:asset) { FactoryGirl.build(:theme_asset,
        site: site,
        plain_text_name: 'test',
        plain_text: 'Lorem ipsum',
        performing_plain_text: true) }

    it 'should handle stylesheet' do
      asset.plain_text_type = 'stylesheet'
      asset.valid?.should be_true
      asset.stylesheet?.should be_true
      asset.source.should_not be_nil
    end

    it 'should handle javascript' do
      asset.plain_text_type = 'javascript'
      asset.valid?.should be_true
      asset.javascript?.should be_true
      asset.source.should_not be_nil
    end

  end

  describe '.escape_shortcut_urls' do

    before(:each) do
      site.theme_assets.expects(:where).with(local_path: 'images/banner.png').returns([image])
    end

    let(:image) { stub(source: OpenStruct.new(url: 'http://engine.dev/images/banner.png')) }

    subject { asset.send(:escape_shortcut_urls, text) }

    context 'simple url' do

      let(:text) { "background: url(/images/banner.png) no-repeat 0 0" }
      it { should == "background: url(http://engine.dev/images/banner.png) no-repeat 0 0" }

    end

    context 'url with quotes' do

      let(:text) { "background: url(\"/images/banner.png\") no-repeat 0 0" }
      it { should == "background: url(\"http://engine.dev/images/banner.png\") no-repeat 0 0" }

    end

    context 'url with quotes and timestamps' do

      let(:text) { "background: url(\"/images/banner.png?123456\") no-repeat 0 0" }
      it { should == "background: url(\"http://engine.dev/images/banner.png\") no-repeat 0 0" }

    end

  end

end
