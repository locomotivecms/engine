require 'spec_helper'

describe Locomotive::Liquid::Tags::SEOMetadata do
  let(:site) do
    Factory.build(:site, :meta_description => 'A short site description', :meta_keywords => 'test only cat dog')
  end

  describe 'rendering' do
    it 'renders a a meta description tag' do
      render_seo_metadata.should include '<meta name="description" content="A short site description" />'
    end

    it 'strips and removes quote characters from the description' do
      site.meta_description = ' String with " " quotes '
      render_seo_metadata.should include '<meta name="description" content="String with   quotes" />'
    end

    it 'renders a meta keywords tag' do
      render_seo_metadata.should include '<meta name="keywords" content="test only cat dog" />'
    end

    it 'strips and removes quote characters from the keywords' do
      site.meta_keywords = ' one " two " three '
      render_seo_metadata.should include '<meta name="keywords" content="one  two  three" />'
    end
  
    context "when page" do
      context "has metadata" do
        let(:page) { site.pages.build(:meta_keywords => 'hulk,gamma', :meta_description => "Bruce Banner") }
        subject { render_seo_metadata('page' => page) }
        it { should include(%Q[<meta name="keywords" content="#{page.meta_keywords}" />]) }
        it { should include(%Q[<meta name="description" content="#{page.meta_description}" />]) }
      end

      context "does not have metadata" do
        let(:page) { site.pages.build } 
        subject { render_seo_metadata('page' => page) }
        it { should include(%Q[<meta name="keywords" content="#{site.meta_keywords}" />]) }
        it { should include(%Q[<meta name="description" content="#{site.meta_description}" />]) }
      end
    end
  
    context "when content instance" do
      let(:content_type) do
        Factory.build(:content_type, :site => site).tap do |ct|
          ct.content_custom_fields.build :label => 'anything', :kind => 'String'
        end
      end

      context "has metadata" do
        let(:content) { content_type.contents.build(:meta_keywords => 'Libidinous, Angsty', :meta_description => "Quite the combination.") }
        subject { render_seo_metadata('content_instance' => content) }
        it { should include(%Q[<meta name="keywords" content="#{content.meta_keywords}" />]) }
        it { should include(%Q[<meta name="description" content="#{content.meta_description}" />]) }
      end

      context "does not have metadata" do
        let(:content) { content_type.contents.build }
        subject { render_seo_metadata('content_instance' => content) }
        it { should include(%Q[<meta name="keywords" content="#{site.meta_keywords}" />]) }
        it { should include(%Q[<meta name="description" content="#{site.meta_description}" />]) }
      end
    end
  end
  

  def render_seo_metadata(assigns={})
    registers = { :site => site }
    liquid_context = ::Liquid::Context.new({}, assigns, registers)
    output = Liquid::Template.parse("{% seo_metadata %}").render(liquid_context)
  end
end