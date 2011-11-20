# coding: utf-8

require 'spec_helper'

describe Asset do

  describe 'attaching a file' do

    before(:each) do
      Asset.any_instance.stubs(:site_id).returns('test')
      @asset = FactoryGirl.build(:asset)
    end

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

  describe 'vignette' do

    before(:each) do
      @asset = FactoryGirl.build(:asset, :source => FixturedAsset.open('5k.png'))
    end

    it 'does not resize image smaller than 50x50' do
      @asset.vignette_url.should =~ /^\/spec\/.*\/5k.png/
    end

    it 'has any possible resized versions' do
      @asset.stubs(:with).returns(81)
      @asset.stubs(:height).returns(81)
      @asset.vignette_url.should =~ /^\/images\/dynamic\/.*\/5k.png/
    end

  end

end