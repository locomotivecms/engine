require 'spec_helper'

describe Locomotive::Liquid::Drops::Page do

  before(:each) do
    @site  = FactoryGirl.build(:site)
    @home  = FactoryGirl.build(:page, site: @site, meta_keywords: 'Libidinous, Angsty', meta_description: "Quite the combination.")
  end

  context '#rendering tree' do

    before(:each) do
      @home.stubs(:children).returns([
        Locomotive::Page.new(title: 'Child #1'),
        Locomotive::Page.new(title: 'Child #2'),
        Locomotive::Page.new(title: 'Child #3')
        ])
      @home.children.last.stubs(:children).returns([
        Locomotive::Page.new(title: 'Child #3.1'),
        Locomotive::Page.new(title: 'Child #3.2')
        ])
    end

    context '#children' do

      it 'renders title of all children pages' do
        content = render_template '{% for child in home.children %}{{ child.title }},{% endfor %}'
        content.should == 'Child #1,Child #2,Child #3,'
      end

    end

    context '#sub children' do

      it 'renders title of all sub children pages' do
        content = render_template '{% for child in home.children.last.children %}{{ child.title }},{% endfor %}'
        content.should == 'Child #3.1,Child #3.2,'
      end

    end

  end

  context '#parent' do
    before(:each) do
      @sub_page = FactoryGirl.build(:sub_page, meta_keywords: 'Sub Libidinous, Angsty', meta_description: "Sub Quite the combination.")
    end

    it 'renders title of parent page' do
      content = render_template '{{ sub_page.parent.title }}', { 'sub_page' => @sub_page }
      content.should == "Home page"
    end

  end

  context '#breadcrumbs' do
    before(:each) do
      @sub_page = FactoryGirl.build(:sub_page, meta_keywords: 'Sub Libidinous, Angsty', meta_description: "Sub Quite the combination.")
      @sub_page.stubs(:ancestors_and_self).returns([FactoryGirl.build(:page), @sub_page])
    end

    it 'renders breadcrumbs of current page' do
      content = render_template '{% for crumb in sub_page.breadcrumbs %}{{ crumb.title }},{% endfor %}', { 'sub_page' => @sub_page }
      content.should == 'Home page,Subpage,'
    end
  end

  context '#rendering page title' do

    it 'renders the title of a normal page' do
      render_template('{{ home.title }}').should == 'Home page'
    end

    it 'renders the content instance highlighted field instead for a templatized page' do
      templatized = FactoryGirl.build(:page, title: 'Lorem ipsum template', templatized: true)

      entry = Locomotive::Liquid::Drops::ContentEntry.new(mock('entry', _label: 'Locomotive rocks !'))

      render_template('{{ page.title }}', 'page' => templatized, 'entry' => entry).should == 'Locomotive rocks !'
    end

  end

  context '#rendering page slug' do

    it 'renders the slug of a normal page' do
      render_template('{{ home.slug }}').should == 'index'
    end

    it 'renders the content instance slug instead for a templatized page' do
      templatized = FactoryGirl.build(:page, title: 'Lorem ipsum template', templatized: true)

      entry = Locomotive::Liquid::Drops::ContentEntry.new(mock('entry', _slug: 'my_entry'))

      render_template('{{ page.slug }}', 'page' => templatized, 'entry' => entry).should == 'my_entry'
    end

  end

  context '#rendering page with editable_elements' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first
      @home.update_attributes raw_template: "{% block body %}{% editable_short_text 'body' %}Lorem ipsum{% endeditable_short_text %}{% endblock %}"
      @home.editable_elements.first.content = 'Lorem ipsum'
    end

    it 'renders the text of the editable field' do
      render_template('{{ home.body }}').should == 'Lorem ipsum'
    end

  end

  describe 'published?' do
    subject { render_template('{{ home.published? }}') }
    it { should == @home.published?.to_s }
  end

  describe 'listed?' do
    subject { render_template('{{ home.listed? }}') }
    it { should == @home.listed?.to_s }
  end

  describe 'meta_keywords' do
    subject { render_template('{{ home.meta_keywords }}') }
    it { should == @home.meta_keywords }
  end

  describe 'meta_description' do
    subject { render_template('{{ home.meta_description }}') }
    it { should == @home.meta_description }
  end

  describe 'templatized?' do

    subject { render_template('{{ page.templatized? }}', { 'page' => page }) }

    context 'by default' do

      let(:page) { @home }
      it { should == 'false' }

    end

    context 'with the templatized flag enabled' do

      let(:page) { FactoryGirl.build(:page, templatized: true) }
      it { should == 'true' }

    end

  end

  describe 'content_type' do

    let(:content_type) do
      FactoryGirl.build(:content_type, site: @site).tap do |_content_type|
        _content_type.entries_custom_fields.build label: 'Name', type: 'string'
        _content_type.save!
        2.times { _content_type.entries.create(name: 'Example') }
      end
    end
    let(:page) { FactoryGirl.build(:page, templatized: true, target_klass_name: content_type.klass_with_custom_fields(:entries).to_s) }

    subject { render_template(template, { 'page' => page }) }

    describe '#content_type' do

      let(:template) { '{{ page.content_type }}' }
      it { should =~ /ContentTypeProxyCollection/ }

    end

    describe '#content_type.count' do

      let(:template) { '{{ page.content_type.count }}' }
      it { should == '2' }

    end

  end

  def render_template(template = '', assigns = {})
    assigns = {
      'home' => @home
    }.merge(assigns)

    Liquid::Template.parse(template).render!(assigns)
  end

end
