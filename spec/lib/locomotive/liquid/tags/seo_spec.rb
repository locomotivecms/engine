require 'spec_helper'

describe Locomotive::Liquid::Tags::SEO do

  let(:site) do
    FactoryGirl.build(:site, :seo_title => 'Site title (SEO)', :meta_description => 'A short site description', :meta_keywords => 'test only cat dog')
  end

  describe 'rendering' do

    it 'renders everything' do
      html = render_seo
      html.should include '<title>Site title (SEO)</title>'
      html.should include '<meta name="description" content="A short site description">'
      html.should include '<meta name="keywords" content="test only cat dog">'
    end

    it 'renders a seo title' do
      render_seo_title.should include '<title>Site title (SEO)</title>'
    end

    it 'renders the site title if no seo title is provided' do
      site.seo_title = nil
      render_seo_title.should include '<title>Acme Website</title>'
    end

    it 'renders a meta description tag' do
      render_seo_metadata.should include '<meta name="description" content="A short site description">'
    end

    it 'strips and removes quote characters from the description' do
      site.meta_description = ' String with " " quotes '
      render_seo_metadata.should include '<meta name="description" content="String with   quotes">'
    end

    it 'renders a meta keywords tag' do
      render_seo_metadata.should include '<meta name="keywords" content="test only cat dog">'
    end

    it 'strips and removes quote characters from the keywords' do
      site.meta_keywords = ' one " two " three '
      render_seo_metadata.should include '<meta name="keywords" content="one  two  three">'
    end

    it 'renders an empty string if no meta' do
      site.meta_keywords = nil
      render_seo_metadata.should include '<meta name="keywords" content="">'
    end

    context "when page" do

      context "has seo title" do
        let(:page) { site.pages.build(:seo_title => 'Page title (SEO)', :meta_keywords => 'hulk,gamma', :meta_description => "Bruce Banner") }
        subject { render_seo_title('page' => page) }
        it { should include(%Q[<title>Page title (SEO)</title>]) }
      end

      context "does not have seo title" do
        let(:page) { site.pages.build }
        subject { render_seo_title('page' => page) }
        it { should include(%Q[<title>Site title (SEO)</title>]) }
      end

      context "has metadata" do
        let(:page) { site.pages.build(:meta_keywords => 'hulk,gamma', :meta_description => "Bruce Banner") }
        subject { render_seo_metadata('page' => page) }
        it { should include(%Q[<meta name="keywords" content="#{page.meta_keywords}">]) }
        it { should include(%Q[<meta name="description" content="#{page.meta_description}">]) }
      end

      context "does not have metadata" do
        let(:page) { site.pages.build }
        subject { render_seo_metadata('page' => page) }
        it { should include(%Q[<meta name="keywords" content="#{site.meta_keywords}">]) }
        it { should include(%Q[<meta name="description" content="#{site.meta_description}">]) }
      end

    end

    context "when content instance" do

      let(:content_type) do
        FactoryGirl.build(:content_type, :site => site).tap do |ct|
          ct.entries_custom_fields.build :label => 'anything', :type => 'string'
        end.tap { |_ct| _ct.valid? }
      end

      context "has seo title" do
        let(:content_entry) { content_type.entries.build(:seo_title => 'Content title (SEO)', :meta_keywords => 'Libidinous, Angsty', :meta_description => "Quite the combination.") }
        subject { render_seo_title('content_entry' => content_entry) }
        it { should include(%Q[<title>Content title (SEO)</title>]) }
      end

      context "does not have seo title" do
        let(:content_entry) { content_type.entries.build }
        subject { render_seo_title('content_entry' => content_entry) }
        it { should include(%Q[<title>Site title (SEO)</title>]) }
      end

      context "has metadata" do
        let(:content_entry) { content_type.entries.build(:meta_keywords => 'Libidinous, Angsty', :meta_description => "Quite the combination.") }
        subject { render_seo_metadata('content_entry' => content_entry) }
        it { should include(%Q[<meta name="keywords" content="#{content_entry.meta_keywords}">]) }
        it { should include(%Q[<meta name="description" content="#{content_entry.meta_description}">]) }
      end

      context "does not have metadata" do
        let(:content_entry) { content_type.entries.build }
        subject { render_seo_metadata('content_entry' => content_entry) }
        it { should include(%Q[<meta name="keywords" content="#{site.meta_keywords}">]) }
        it { should include(%Q[<meta name="description" content="#{site.meta_description}">]) }
      end

    end

  end

  def render_seo(assigns = {})
    render_seo_tag('seo', assigns)
  end

  def render_seo_title(assigns = {})
    render_seo_tag('seo_title', assigns)
  end

  def render_seo_metadata(assigns = {})
    render_seo_tag('seo_metadata', assigns)
  end

  def render_seo_tag(tag_name, assigns = {})
    registers = { :site => site }
    liquid_context = ::Liquid::Context.new({}, assigns, registers)
    output = Liquid::Template.parse("{% #{tag_name} %}").render(liquid_context)
  end
end
