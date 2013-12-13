require 'spec_helper'

describe Locomotive::Liquid::Tags::PathTo do

  before(:each) { I18n.locale = :en }

  let(:site)    { FactoryGirl.create("test site") }
  let(:assigns) { {} }

  subject { render(template, assigns) }

  context 'no page responding to the handle' do

    let(:template) { "{% path_to unknown-page %}" }

    it { should be_blank }

  end

  context 'no page responding to the handle' do

    let(:assigns)   { { 'project' => Locomotive::ContentEntry.new(_slug: 'hello-world', _label_field_name: :_slug ) } }
    let(:template)  { "{% path_to project %}" }

    it { should be_blank }

  end

  describe 'page responding to the handle' do

    let(:page)      { create_page(site, 'Hello world', 'my-page') }
    let(:template)  { "{% path_to my-page %}" }
    before(:each)   { page }

    it { should == %{/hello-world} }

    context 'passing a page directly' do

      let(:assigns)   { { 'page' => page } }
      let(:template)  { "{% path_to page %}" }

      it { should == %{/hello-world} }

    end

  end

  describe 'templatized page' do

    let(:parent_page)   { create_page(site, 'List of projects') }
    let(:page)          { create_templatized_page(site, 'Template', 'project-template', parent_page, content_type) }
    let(:content_type)  { create_content_type(site, 'Projects') }
    let(:content_entry) { create_content_entry(content_type, name: 'My fancy project') }
    let(:assigns)       { { 'project' => content_entry } }
    before(:each)       { page }

    context 'without passing the handle' do

      let(:template) { "{% path_to project %}" }

      it { should == %{/list-of-projects/my-fancy-project} }

    end

    context 'forcing the page' do

      let(:another_parent_page)   { create_page(site, 'Another list of projects') }
      let(:another_page)          { create_templatized_page(site, 'Template', 'another-project-template', another_parent_page, content_type) }
      let(:template)              { "{% path_to project, with: another-project-template %}" }
      before(:each)               { another_page }

      it { should == %{/another-list-of-projects/my-fancy-project} }

    end

  end

  def render(template, assigns = {})
    liquid_context = ::Liquid::Context.new({},
      { 'contents' => Locomotive::Liquid::Drops::ContentTypes.new }.merge(assigns),
      { site: site })
    output = Liquid::Template.parse(template).render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

  def create_page(site, title, handle = nil, parent = nil)
    parent ||= site.pages.root.first
    site.pages.create!(parent: parent, title: title, slug: title.permalink, handle: handle)
  end

  def create_templatized_page(site, title, handle, parent, content_type)
    site.pages.create!(
      parent:             parent,
      title:              title,
      handle:             handle,
      templatized:        true,
      target_klass_name:  content_type.klass_with_custom_fields(:entries).to_s)
  end

  def create_content_type(site, name)
    FactoryGirl.build(:content_type, site: site, name: name).tap do |content_type|
      content_type.entries_custom_fields.build(name: 'name', type: 'string', label: 'name')
      content_type.save!
    end
  end

  def create_content_entry(content_type, attributes)
    content_type.entries.create!(attributes)
  end

end