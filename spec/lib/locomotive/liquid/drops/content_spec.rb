require 'spec_helper'

describe Locomotive::Liquid::Drops::Content do

  before(:each) do
    @site = Factory.build(:site)
    content_type = Factory.build(:content_type)
    content_type.content_custom_fields.build :label => 'anything', :kind => 'String'
    @content = content_type.contents.build(:meta_keywords => 'Libidinous, Angsty', :meta_description => "Quite the combination.")
  end

  describe 'meta_keywords' do
    subject { render_template('{{ content.meta_keywords }}') }
    it { should == @content.meta_keywords }
  end

  describe 'meta_description' do
    subject { render_template('{{ content.meta_description }}') }
    it { should == @content.meta_description }
  end

  def render_template(template = '', assigns = {})
    assigns = { 'content' => @content }.merge(assigns)
    Liquid::Template.parse(template).render(::Liquid::Context.new({}, assigns, { :site => @site }))
  end

end
