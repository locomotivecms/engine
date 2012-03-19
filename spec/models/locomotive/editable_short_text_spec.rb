require 'spec_helper'

describe Locomotive::EditableShortText do

  describe 'a simple case' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first

      @home.update_attributes :raw_template => "{% block body %}{% editable_short_text 'body' %}Lorem ipsum{% endeditable_short_text %}{% endblock %}"

      @sub_page_1 = FactoryGirl.create(:page, :slug => 'sub_page_1', :parent => @home, :raw_template => "{% extends 'parent' %}")
      @sub_page_2 = FactoryGirl.create(:page, :slug => 'sub_page_2', :parent => @home, :raw_template => "{% extends 'parent' %}")

      @sub_page_1_el = @sub_page_1.editable_elements.first

      @sub_page_1_1 = FactoryGirl.create(:page, :slug => 'sub_page_1_1', :parent => @sub_page_1, :raw_template => "{% extends 'parent' %}")
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

      it 'does not have a content at first' do
        @sub_page_1_el.content.should be_nil
        @sub_page_1_el.default_content.should be_true
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

  describe '"sticky" elements' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first

      @home.update_attributes :raw_template => "{% block body %}{% editable_short_text 'body', fixed: true %}Lorem ipsum{% endeditable_short_text %}{% endblock %}"
      @home_el = @home.editable_elements.first

      @sub_page_1 = FactoryGirl.create(:page, :slug => 'sub_page_1', :parent => @home, :raw_template => "{% extends 'parent' %}")
      @sub_page_2 = FactoryGirl.create(:page, :slug => 'sub_page_2', :parent => @home, :raw_template => "{% extends 'parent' %}")

      @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2_el = @sub_page_2.editable_elements.first
    end

    it 'exists in sub pages' do
      @sub_page_1.editable_elements.size.should == 1
      @sub_page_2.editable_elements.size.should == 1
    end

    it 'is marked as fixed' do
      @sub_page_1_el.fixed?.should be_true
      @sub_page_2_el.fixed?.should be_true
    end

    it 'enables the default content when it just got created' do
      @sub_page_1_el.default_content?.should be_true
    end

    it 'disables the default content if the content changed' do
      @sub_page_1_el.content = 'Bla bla'
      @sub_page_1_el.default_content?.should be_false
    end

    it 'gets also updated when updating the very first element' do
      @home_el.content = 'Hello world'
      @home.save
      @sub_page_1.reload; @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2.reload; @sub_page_2_el = @sub_page_2.editable_elements.first
      @sub_page_1_el.content.should == 'Hello world'
      @sub_page_2_el.content.should == 'Hello world'
    end

  end

end