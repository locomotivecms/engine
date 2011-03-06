require 'spec_helper'

describe EditableElement do

  before(:each) do
    @site = Factory(:site)
    @home = @site.pages.root.first
    @home.update_attributes :raw_template => "{% block body %}{% editable_short_text 'body' %}Lorem ipsum{% endeditable_short_text %}{% endblock %}"

    @sub_page_1 = Factory(:page, :slug => 'sub_page_1', :parent => @home, :raw_template => "{% extends 'parent' %}")
    @sub_page_2 = Factory(:page, :slug => 'sub_page_2', :parent => @home, :raw_template => "{% extends 'parent' %}")

    @sub_page_1_1 = Factory(:page, :slug => 'sub_page_1_1', :parent => @sub_page_1, :raw_template => "{% extends 'parent' %}")
  end

  context 'in sub pages level #1' do

    before(:each) do
      @sub_page_1.reload
      @sub_page_2.reload
    end

    it 'exists' do
      @sub_page_1.editable_elements.size.should == 1
      @sub_page_2.editable_elements.size.should == 1
    end

    it 'has a non-nil slug' do
      @sub_page_1.editable_elements.first.slug.should == 'body'
    end

  end

  context 'in sub pages level #2' do

    before(:each) do
      @sub_page_1_1.reload
    end

    it 'exists' do
      @sub_page_1_1.editable_elements.size.should == 1
    end

    it 'has a non-nil slug' do
      @sub_page_1_1.editable_elements.first.slug.should == 'body'
    end

    it 'removes editable elements' do
      @sub_page_1_1.editable_elements.destroy_all
      @sub_page_1_1.reload
      @sub_page_1_1.editable_elements.size.should == 0
    end

  end
end