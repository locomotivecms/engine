require 'spec_helper'

describe Locomotive::EditableControl do

  before(:each) do
    @site = FactoryGirl.create(:site)
    @home = @site.pages.root.first
  end

  describe '#simple' do

    before(:each) do
      @home.update_attributes raw_template: "{% block body %}{% editable_control 'menu', options: 'true=Yes,false=No' %}false{% endeditable_control %}{% endblock %}"

      @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
    end

    it 'exists' do
      @sub_page_1.editable_elements.size.should == 1
    end

    it 'has a non-nil slug' do
      @sub_page_1.editable_elements.first.slug.should == 'menu'
    end

    it 'has a default value' do
      @sub_page_1.editable_elements.first.content.should == 'false'
    end

    it 'has a list of options' do
      @sub_page_1.editable_elements.first.options.should == [{ 'value' => 'true', 'text' => 'Yes' }, { 'value' => 'false', 'text' => 'No' }]
    end

    it 'removes leading and trailling characters' do
      @home.update_attributes raw_template: %({% block body %}
      {% editable_control 'menu', options: 'true=Yes,false=No' %}
        true
      {% endeditable_control %}
      {% endblock %})
      @home.editable_elements.first.content.should == 'true'
    end

  end

  describe '"sticky" elements' do

    before(:each) do
      @home.update_attributes raw_template: "{% block body %}{% editable_control 'menu', options: 'true=Yes,false=No', fixed: true %}false{% endeditable_control %}{% endblock %}"
      @home_el = @home.editable_elements.first

      @sub_page_1 = FactoryGirl.create(:page, slug: 'sub_page_1', parent: @home, raw_template: "{% extends 'parent' %}")
      @sub_page_2 = FactoryGirl.create(:page, slug: 'sub_page_2', parent: @home, raw_template: "{% extends 'parent' %}")

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

    it 'gets also updated when updating the very first element' do
      @home_el.content = 'true'
      @home.save
      @sub_page_1.reload; @sub_page_1_el = @sub_page_1.editable_elements.first
      @sub_page_2.reload; @sub_page_2_el = @sub_page_2.editable_elements.first
      @sub_page_1_el.content.should == 'true'
      @sub_page_2_el.content.should == 'true'
    end

  end

end