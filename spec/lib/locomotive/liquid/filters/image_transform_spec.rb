require 'spec_helper'

describe Locomotive::Liquid::Filters::Imagetransform do

  include Locomotive::Liquid::Filters::Imagetransform

  before(:each) do
    @context = build_context
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

      it 'should return the given input'

    end

  end

  def build_context
    klass = Class.new
    klass.class_eval do
      def registers
        { :site => Factory.build(:site, :id => fake_bson_id(42)) }
      end

      def fake_bson_id(id)
        BSON::ObjectId(id.to_s.rjust(24, '0'))
      end
    end
    klass.new
  end

end
