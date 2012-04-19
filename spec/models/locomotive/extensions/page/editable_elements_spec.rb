require 'spec_helper'

describe Locomotive::Extensions::Page::EditableElements do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first

    @home.update_attributes :raw_template => "{% editable_short_text 'body' %}Lorem ipsum{% endeditable_short_text %}"

    @sub_page_1 = FactoryGirl.create(:page, :slug => 'sub_page_1', :parent => @home, :raw_template => "{% extends 'parent' %}")
    @sub_page_2 = FactoryGirl.create(:page, :slug => 'sub_page_2', :parent => @home, :raw_template => "{% extends 'parent' %}")

    @sub_page_1_el = @sub_page_1.editable_elements.first

    @sub_page_1_1 = FactoryGirl.create(:page, :slug => 'sub_page_1_1', :parent => @sub_page_1, :raw_template => "{% extends 'parent' %}")
  end

  describe 'modification of an element within the home page' do

    before(:each) do
      @home = Locomotive::Page.find(@home._id)
    end

    it 'changes the type of the element in all the children' do
      @home.update_attributes :raw_template => "{% editable_long_text 'body' %}Lorem ipsum{% endeditable_long_text %}"
      @sub_page_1.reload
      @sub_page_1.editable_elements.first._type.should == 'Locomotive::EditableLongText'
      @sub_page_1_1.reload
      @sub_page_1_1.editable_elements.first._type.should == 'Locomotive::EditableLongText'
    end

    it 'changes the hint of the element in all the children' do
      @home.update_attributes :raw_template => "{% editable_long_text 'body', hint: 'My very useful hint' %}Lorem ipsum{% endeditable_long_text %}"
      @sub_page_1.reload
      @sub_page_1.editable_elements.first.hint.should == 'My very useful hint'
      @sub_page_1_1.reload
      @sub_page_1_1.editable_elements.first.hint.should == 'My very useful hint'
    end

  end

end
