require 'spec_helper'

describe Locomotive::Liquid::Filters::Resize do

  before :all do
    @asset_url  = '/path/to/image.jpg'
    @asset      = Factory.create(:asset, :collection => Factory.build(:asset_collection), :source => FixturedAsset.open('5k.png'))
    @asset_path = "/sites/#{@asset.collection.site_id}/assets/#{@asset.id}"
    @context    = Liquid::Context.new({}, { 'asset' => @asset, 'asset_url' => @asset_url })
  end

  after :all do
    # Cleanup
    @asset.destroy
  end

  describe '#resize' do

    context 'when an asset is given' do

      context 'when only a height is given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset | resize: "height:900" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == "#{@asset_path}/5k_x900.png"
        end

      end

      context 'when only a width is given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset | resize: "width:400px" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == "#{@asset_path}/5k_400x.png"
        end

      end

      context 'when both a width and height are given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset | resize: "width:400px", "height:900" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == "#{@asset_path}/5k_400x900.png"
        end

      end

    end

    context 'when an asset url string is given' do

      context 'when only a height is given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset_url | resize: "height:900" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == '/path/to/image_x900.jpg'
        end

      end

      context 'when only a width is given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset_url | resize: "width:400px" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == '/path/to/image_400x.jpg'
        end

      end

      context 'when both a width and height are given' do

        before :all do
          @template = Liquid::Template.parse('{{ asset_url | resize: "width:400px", "height:900" }}')
        end

        it 'should return the location of the resized image' do
          @template.render(@context).should == '/path/to/image_400x900.jpg'
        end

      end

    end

    context 'when no height and width is given' do

      before :all do
        @template = Liquid::Template.parse('{{ asset | resize }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error: width or height is required'
      end

    end

    context 'when an invalid width or height is given' do

      before :all do
        @template = Liquid::Template.parse('{{ asset | resize: "width: NaNpx" }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error: width or height is required'
      end

    end

  end

end
