require 'spec_helper'

describe Locomotive::EditableFile do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first

    @home.update_attributes :raw_template => "{% block body %}{% editable_file 'image' %}Lorem ipsum{% endeditable_file %}{% endblock %}"

    @home = @site.pages.root.first
  end

  it 'has one editable file element' do
    @home.editable_elements.size.should == 1
    @home.editable_elements.first.slug.should == 'image'
  end

  it 'does not have 2 image fields' do
    editable_file = @home.editable_elements.first
    fields = editable_file.class.fields.keys
    (fields.include?('source') && fields.include?(:source)).should be_false
  end

  context 'with an attached file' do

    before(:each) do
      @editable_file = @home.editable_elements.first
      @editable_file.source = FixturedAsset.open('5k.png')
      @home.save
    end

    it 'has a valid source' do
      @editable_file.source?.should be_true
    end

    it 'returns the right path even if the page has been retrieved with the minimum_attributes scope' do
      @home = @site.pages.minimal_attributes(%w(editable_elements)).root.first
      @home.editable_elements.first.source?.should be_true
    end

  end

end
