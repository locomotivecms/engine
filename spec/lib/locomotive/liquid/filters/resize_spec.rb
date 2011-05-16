require 'spec_helper'

describe Locomotive::Liquid::Filters::Resize do

  before :each do
    @site        = Factory.create(:site)
    @asset_url   = '/path/to/image.jpg'
    @theme_asset = Factory.create(:theme_asset, :source => FixturedAsset.open('5k.png'), :site => @site)
    @asset       = Factory.create(:asset, :collection => Factory.build(:asset_collection), :source => FixturedAsset.open('5k.png'))
    @asset_path  = "/sites/#{@asset.collection.site_id}/assets/#{@asset.id}"
    @context     = Liquid::Context.new( { }, { 'asset' => @asset, 'asset_url' => @asset_url, 'theme_asset' => @theme_asset }, { :site => @site })
    @app         = Dragonfly[:images]
  end

  describe '#resize' do

    context 'when an asset is given' do

      context 'which has an uploader using the local filesystem' do

        before :each do
          @asset.source.class.storage = :file
          @template = Liquid::Template.parse('{{ asset | resize: "900x100" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should =~ /media\/.*\/5k.png/
        end

        it 'should use the current path of the asset to generate a location' do
          @template.render(@context).should == @app.fetch_file(@asset.source.current_path).thumb('900x100').url
        end

      end

      context 'which has an uploader using a remote file system' do

        before :each do
          @asset.source.class.storage = :s3
          @template = Liquid::Template.parse('{{ asset | resize: "200x110" }}')
        end

        after :each do
          @asset.source.class.storage = :file # Reset to file
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should =~ /media\/.*\/5k.png/
        end

        it 'should use the url of the asset to generate a location' do
          @template.render(@context).should == @app.fetch_url(@asset.source.url).thumb('200x110').url
        end

      end

    end

    context 'when an asset url string is given' do

      before :each do
        @template = Liquid::Template.parse('{{ asset_url | resize: "40x30" }}')
      end

      it 'should return the location of the resized image' do
        @template.render(@context).should =~ /media\/.*\/image.jpg/
      end

      it 'should use the path in the public folder to generate a location' do
        @template.render(@context).should == @app.fetch_file("public/#{@asset_url}").thumb('40x30').url
      end

    end

    context 'when a theme asset is given' do

      before :each do
        @template = Liquid::Template.parse('{{ theme_asset | resize: "300x400" }}')
      end

      it 'should return the location of the resized image' do
        @template.render(@context).should =~ /media\/.*\/5k.png/
      end

      it 'should use the path of the theme asset to generate a location' do
        @template.render(@context).should == @app.fetch_file(@theme_asset.source.current_path).thumb('300x400').url
      end

    end

    context 'when no resize string is given' do

      before :each do
        @template = Liquid::Template.parse('{{ asset | resize: }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error: wrong number of arguments'
      end

    end

  end

end
