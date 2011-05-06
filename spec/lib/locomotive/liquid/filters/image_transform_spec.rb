require 'spec_helper'

describe Locomotive::Liquid::Filters::Imagetransform do

  before :all do
    @asset   = Factory.build(:theme_asset)
    @context = Liquid::Context.new({},{ 'asset' => @asset })
  end

  describe '#transform' do

    context 'when a valid transform is given' do

      context 'when there is already a processed image' do

        before :all do
          @template = Liquid::Template.parse('{{ asset | transform: "400x900" }}')
        end

        it 'should return the location of the image' do
          @template.render(@context).should == 'image_400_900.jpg'
        end

        it 'should not process the image again'

      end

      context 'when there is not already a procesed image' do

        it 'should process the image'

        it 'should set the width of the image to match the given width'

        it 'should set the height of the image to match the given width'

        it 'should return the location of the processed image'

      end

    end

    context 'when an invalid transform is given' do

      before :all do
        @template = Liquid::Template.parse('{{ asset | transform: "invalid" }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should == 'Liquid error: invalid format for transform'
      end

    end

    context 'when no transform string is given' do

      before :all do
        @template = Liquid::Template.parse('{{ asset | transform }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error: wrong number of arguments'
      end

    end

  end

end
