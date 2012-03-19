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

  it 'does not have a content at first' do
    @sub_page_1.editable_elements.first.content.should be_nil
    @sub_page_1.editable_elements.first.default_content.should be_true
  end

end