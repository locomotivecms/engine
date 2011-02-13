require 'spec_helper'

describe Locomotive::Liquid::Tags::SEOMetadata do

  before :each do
    @site = Factory.build(:site, :meta_description => 'A short site description', :meta_keywords => 'test only cat dog')
  end

  context '#rendering' do

    it 'renders a a meta description tag' do
      render_seo_metadata.should include '<meta name="description" content="A short site description" />'
    end

    it 'strips and removes quote characters from the description' do
      @site.meta_description = ' String with " " quotes '
      render_seo_metadata.should include '<meta name="description" content="String with   quotes" />'
    end

    it 'renders a meta keywords tag' do
      render_seo_metadata.should include '<meta name="keywords" content="test only cat dog" />'
    end

    it 'strips and removes quote characters from the keywords' do
      @site.meta_keywords = ' one " two " three '
      render_seo_metadata.should include '<meta name="keywords" content="one  two  three" />'
    end

  end

  def render_seo_metadata
    registers = { :site => @site }
    liquid_context = ::Liquid::Context.new({}, {}, registers)
    output = Liquid::Template.parse("{% seo_metadata %}").render(liquid_context)
  end

end