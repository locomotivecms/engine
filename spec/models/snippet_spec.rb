require 'spec_helper'

describe Snippet do

  it 'should have a valid factory' do
    Factory.build(:snippet).should be_valid
  end
  
  # Validations ##

  %w{site name template}.each do |field|
    it "should validate presence of #{field}" do
      template = Factory.build(:snippet, field.to_sym => nil)
      template.should_not be_valid
      template.errors[field.to_sym].should == ["can't be blank"]
    end
  end

  describe '#update_templates' do
  
    before :each do
      @site    = Factory(:site, :subdomain => 'omg')
      @snippet = Factory(:snippet, :site => @site, :slug => 'my_test_snippet', :template => 'a testing template')
      @page    = Factory(:page, :site => @site, :slug => 'my_page_here', :raw_template => "{% include 'my_test_snippet'  %}")
    end

    it 'should update any templates with the new snippet template' do
      @snippet.update_attributes(:template => 'a new template')
      @page = Page.last # Reload the page
      @page.render({}).should == 'a new template'
    end

  end

end
