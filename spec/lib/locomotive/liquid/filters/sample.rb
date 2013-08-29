require 'spec_helper'

describe Locomotive::Liquid::Filters::Sample do

  include Locomotive::Liquid::Filters::Sample

  let(:site) do
    FactoryGirl.build(:site)
  end

  let(:content_type) do
    FactoryGirl.build(:content_type, site: site).tap do |ct|
      ct.entries_custom_fields.build label: 'anything', type: 'string'
    end.tap { |_ct| _ct.valid? }
  end

  it 'return a sample of a content type collection' do
    content_entries = [content_type.entries.build, content_type.entries.build, content_type.entries.build]
    (content_entries - sample(content_entries, 2)).size.should eql 1
  end

  it 'return a sample of an array' do
    array = ["Foo", "Bar", "Locomotive"]
    (array - sample(array, 1)).size.should eql 2
  end


end
