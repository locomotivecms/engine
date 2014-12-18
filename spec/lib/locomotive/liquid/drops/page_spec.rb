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
        expect(content).to eq 'Child #1,Child #2,Child #3,'
      end

    end

    context '#sub children' do

      it 'renders title of all sub children pages' do
        content = render_template '{% for child in home.children.last.children %}{{ child.title }},{% endfor %}'
        expect(content).to eq 'Child #3.1,Child #3.2,'
      end

    end

  end

  context '#parent' do
    before(:each) do
      @sub_page = FactoryGirl.build(:sub_page, meta_keywords: 'Sub Libidinous, Angsty', meta_description: "Sub Quite the combination.")
    end

    it 'renders title of parent page' do
      content = render_template '{{ sub_page.parent.title }}', { 'sub_page' => @sub_page }
      expect(content).to eq "Home page"
    end

  end

  context '#breadcrumbs' do
    before(:each) do
      @sub_page = FactoryGirl.build(:sub_page, meta_keywords: 'Sub Libidinous, Angsty', meta_description: "Sub Quite the combination.")
      @sub_page.stubs(:ancestors_and_self).returns([FactoryGirl.build(:page), @sub_page])
    end

    it 'renders breadcrumbs of current page' do
      content = render_template '{% for crumb in sub_page.breadcrumbs %}{{ crumb.title }},{% endfor %}', { 'sub_page' => @sub_page }
      expect(content).to eq 'Home page,Subpage,'
    end
  end

  context '#rendering page title' do

    it 'renders the title of a normal page' do
      expect(render_template('{{ home.title }}')).to eq 'Home page'
    end

    it 'renders the content instance highlighted field instead for a templatized page' do
      templatized = FactoryGirl.build(:page, title: 'Lorem ipsum template', templatized: true)

      entry = Locomotive::Liquid::Drops::ContentEntry.new(mock('entry', _label: 'Locomotive rocks !'))

      expect(render_template('{{ page.title }}', 'page' => templatized, 'entry' => entry)).to eq 'Locomotive rocks !'
      expect(render_template('{{ page.original_title }}', 'page' => templatized, 'entry' => entry)).to eq 'Lorem ipsum template'
    end

  end

  context '#rendering page slug' do

    it 'renders the slug of a normal page' do
      expect(render_template('{{ home.slug }}')).to eq 'index'
    end

    it 'renders the content instance slug instead for a templatized page' do
      templatized = FactoryGirl.build(:page, title: 'Lorem ipsum template', slug: 'content-type-template', templatized: true)

      entry = Locomotive::Liquid::Drops::ContentEntry.new(mock('entry', _slug: 'my_entry'))

      expect(render_template('{{ page.slug }}', 'page' => templatized, 'entry' => entry)).to eq 'my_entry'
      expect(render_template('{{ page.original_slug }}', 'page' => templatized, 'entry' => entry)).to eq 'content-type-template'
    end

  end

  context '#rendering page with editable_elements' do

    before(:each) do
      @site = FactoryGirl.create(:site)
      @home = @site.pages.root.first
      @home.update_attributes raw_template: "{% editable_text title %}Hello world{% endeditable_text %}{% block body %}{% editable_short_text 'message' %}Lorem ipsum{% endeditable_short_text %}{% endblock %}"
      @home.editable_elements.first.content = 'Lorem ipsum'
    end

    it 'renders the text of the editable field' do
      expect(render_template('{{ home.editable_elements.body.message }}')).to eq 'Lorem ipsum'
    end

  end

  describe 'published?' do
    subject { render_template('{{ home.published? }}') }
    it { is_expected.to eq @home.published?.to_s }
  end

  describe 'listed?' do
    subject { render_template('{{ home.listed? }}') }
    it { is_expected.to eq @home.listed?.to_s }
  end

  describe 'meta_keywords' do
    subject { render_template('{{ home.meta_keywords }}') }
    it { is_expected.to eq @home.meta_keywords }
  end

  describe 'meta_description' do
    subject { render_template('{{ home.meta_description }}') }
    it { is_expected.to eq @home.meta_description }
  end

  describe 'templatized?' do

    subject { render_template('{{ page.templatized? }}', { 'page' => page }) }

    context 'by default' do

      let(:page) { @home }
      it { is_expected.to eq 'false' }

    end

    context 'with the templatized flag enabled' do

      let(:page) { FactoryGirl.build(:page, templatized: true) }
      it { is_expected.to eq 'true' }

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
      it { is_expected.to match /ContentTypeProxyCollection/ }

    end

    describe '#content_type.count' do

      let(:template) { '{{ page.content_type.count }}' }
      it { is_expected.to eq '2' }

    end

  end

  def render_template(template = '', assigns = {})
    assigns = {
      'home' => @home
    }.merge(assigns)

    Liquid::Template.parse(template).render!(assigns)
  end

end
