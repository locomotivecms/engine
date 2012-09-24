require 'spec_helper'

describe Locomotive::EditableLongText do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first

    @home.update_attributes :raw_template => "{% block body %}{% editable_long_text 'body' %}Lorem ipsum{% endeditable_long_text %}{% endblock %}"

    @sub_page_1 = FactoryGirl.create(:page, :slug => 'sub_page_1', :parent => @home, :raw_template => "{% extends 'parent' %}")
  end

  it 'exists' do
    @sub_page_1.editable_elements.size.should == 1
  end

  it 'has a non-nil slug' do
    @sub_page_1.editable_elements.first.slug.should == 'body'
  end

  it 'has a default content at first' do
    @sub_page_1.editable_elements.first.default_content.should be_true
    @sub_page_1.editable_elements.first.content.should == 'Lorem ipsum'
  end

  it 'is still default when it gets modified by the exact same value' do
    @sub_page_1.editable_elements.first.content = 'Lorem ipsum'
    @sub_page_1.editable_elements.first.default_content.should be_true
  end

  describe 'when modifying the raw template' do

    it 'can update its content from the raw template if the user has not modified it' do
      @home.update_attributes :raw_template => "{% block body %}{% editable_long_text 'body' %}Lorem ipsum v2{% endeditable_long_text %}{% endblock %}"
      @home.editable_elements.first.default_content.should be_true
      @home.editable_elements.first.content.should == 'Lorem ipsum v2'
    end

    it 'does not touch the content if the user has modified it before' do
      @home.editable_elements.first.content = 'Hello world'
      @home.raw_template = "{% block body %}{% editable_long_text 'body' %}Lorem ipsum v2{% endeditable_long_text %}{% endblock %}"
      @home.save
      @home.editable_elements.first.default_content.should be_false
      @home.editable_elements.first.content.should == 'Hello world'
    end

  end

end