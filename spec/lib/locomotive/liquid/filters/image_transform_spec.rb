require 'spec_helper'

describe Locomotive::Liquid::Filters::Imagetransform do

  before :all do
    @context = Liquid::Context.new
    @page    = Factory.build(:page)
  end

  describe '#transform' do

    context 'when a valid transform is given' do

      context 'when there is already a processed image' do

        it 'should return the location of the image'

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
        @template = Liquid::Template.parse('{{ "image.jpg" | transform: "invalid" }}')
      end

      it 'should return the given input' do
        @template.render(@context).should == 'image.jpg'
      end

    end

    context 'when no transform string is given' do

      before :all do
        @template = Liquid::Template.parse('{{ "image.jpg" | transform }}')
      end

      it 'should return a liquid error' do
        @template.render(@context).should include 'Liquid error'
      end

    end

  end

end
