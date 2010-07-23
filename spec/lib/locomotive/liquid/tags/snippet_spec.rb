require 'spec_helper'

describe Locomotive::Liquid::Tags::Snippet do

  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    site = Factory.build(:site)
    snippet = Factory.build(:snippet, :site => site)
    snippet.send(:store_template)
    site.snippets.stubs(:where).returns([snippet])
    @context = ::Liquid::Context.new({}, { :site => site })
  end

  it 'should render it' do
    template = ::Liquid::Template.parse("{% include 'header' %}")
    text = template.render(@context)
    text.should == "<title>Acme</title>"
  end

end
