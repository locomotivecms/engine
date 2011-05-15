# coding: utf-8

require 'spec_helper'

describe ThemeAsset do

  before :all do
    ThemeAssetUploader.enable_processing = true
  end

  after :all do
    ThemeAssetUploader.enable_processing = false
  end

  describe 'attaching a file' do

    before(:each) do
      ThemeAsset.any_instance.stubs(:site_id).returns('test')
      @asset = Factory.build(:theme_asset)
    end

    describe 'file is a picture' do

      it 'should process picture' do
        @asset.source = FixturedAsset.open('5k.png')
        @asset.source.file.content_type.should_not be_nil
        @asset.image?.should be_true
      end

      it 'should get width and height from the image' do
        @asset.source = FixturedAsset.open('5k.png')
        @asset.width.should == 32
        @asset.height.should == 32
      end

    end

    describe 'local path and folder' do

      it 'should set the local path based on the content type' do
        @asset.source = FixturedAsset.open('5k.png')
        @asset.save
        @asset.local_path.should == 'images/5k.png'
      end

      it 'should set the local path based on the folder' do
        @asset.folder = 'trash'
        @asset.source = FixturedAsset.open('5k.png')
        @asset.save
        @asset.local_path.should == 'images/trash/5k.png'
      end

      it 'should set sanitize the local path' do
        @asset.folder = '/images/à la poubelle'
        @asset.source = FixturedAsset.open('5k.png')
        @asset.save
        @asset.local_path.should == 'images/a_la_poubelle/5k.png'
      end

    end

    describe '#validation' do

      it 'does not accept text file' do
        @asset.source = FixturedAsset.open('wrong.txt')
        @asset.valid?.should be_false
        @asset.errors[:source].should_not be_blank
      end

      it 'is not valid if another file with the same path exists' do
        @asset.source = FixturedAsset.open('5k.png')
        @asset.save!

        another_asset = Factory.build(:theme_asset, :site => @asset.site)
        another_asset.source = FixturedAsset.open('5k.png')
        another_asset.valid?.should be_false
        another_asset.errors[:local_path].should_not be_blank
      end

    end

    it 'should process stylesheet' do
      @asset.source = FixturedAsset.open('main.css')
      @asset.source.file.content_type.should_not be_nil
      @asset.stylesheet?.should be_true
    end

    it 'should process javascript' do
      @asset.source = FixturedAsset.open('application.js')
      @asset.source.file.content_type.should_not be_nil
      @asset.javascript?.should be_true
    end

    it 'should get size' do
      @asset.source = FixturedAsset.open('main.css')
      @asset.size.should == 25
    end

  end

  describe 'creating from plain text' do

    before(:each) do
      ThemeAsset.any_instance.stubs(:site_id).returns('test')
      @asset = Factory.build(:theme_asset, {
        :site => Factory.build(:site),
        :plain_text_name => 'test',
        :plain_text => 'Lorem ipsum',
        :performing_plain_text => true
      })
    end

    it 'should handle stylesheet' do
      @asset.content_type = 'stylesheet'
      @asset.valid?.should be_true
      @asset.stylesheet?.should be_true
      @asset.source.should_not be_nil
    end

    it 'should handle javascript' do
      @asset.content_type = 'javascript'
      @asset.valid?.should be_true
      @asset.javascript?.should be_true
      @asset.source.should_not be_nil
    end

  end

end
