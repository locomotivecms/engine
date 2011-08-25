require 'spec_helper'

describe Snippet do

  it 'should have a valid factory' do
    FactoryGirl.build(:snippet).should be_valid
  end

  # Validations ##

  %w{site name template}.each do |field|
    it "should validate presence of #{field}" do
      template = FactoryGirl.build(:snippet, field.to_sym => nil)
      template.should_not be_valid
      template.errors[field.to_sym].should == ["can't be blank"]
    end
  end

  describe '#update_templates' do

    before :each do
      @site    = FactoryGirl.create(:site, :subdomain => 'omg')
      @snippet = FactoryGirl.create(:snippet, :site => @site, :slug => 'my_test_snippet', :template => 'a testing template')
    end

    context 'with a normal top level snippet' do

      before :each do
        @page = FactoryGirl.create(:page, :site => @site, :slug => 'my_page_here', :raw_template => "{% include 'my_test_snippet'  %}")
      end

      it 'updates templates with the new snippet template' do
        @snippet.update_attributes(:template => 'a new template')
        Page.find(@page.id).render({}).should == 'a new template'
      end

    end

    context 'for snippets inside of a block' do

      before :each do
        @page = FactoryGirl.create(:page, :site => @site, :slug => 'my_page_here', :raw_template => "{% block main %}{% include 'my_test_snippet'  %}{% endblock %}")
      end

      it 'updates templates with the new snippet template' do
        @snippet.update_attributes(:template => 'a new template')
        Page.find(@page.id).render({}).should == 'a new template'
      end

    end

  end

end
