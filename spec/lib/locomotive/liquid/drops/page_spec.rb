require 'spec_helper'

describe Locomotive::Liquid::Drops::Page do

  before(:each) do
    site = Factory.build(:site)
    @home = Factory.build(:page, :site => site, :meta_keywords => 'Libidinous, Angsty', :meta_description => "Quite the combination.")
  end

  context '#rendering tree' do

    before(:each) do
      @home.stubs(:children).returns([
        Page.new(:title => 'Child #1'),
        Page.new(:title => 'Child #2'),
        Page.new(:title => 'Child #3')
        ])
      @home.children.last.stubs(:children).returns([
        Page.new(:title => 'Child #3.1'),
        Page.new(:title => 'Child #3.2')
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

  context '#rendering page title' do

    it 'renders the title of a normal page' do
      render_template('{{ home.title }}').should == 'Home page'
    end

    it 'renders the content instance highlighted field instead for a templatized page' do
      templatized = Factory.build(:page, :title => 'Lorem ipsum template', :templatized => true)

      content_instance = Locomotive::Liquid::Drops::Content.new(mock('content_instance', :highlighted_field_value => 'Locomotive rocks !'))

      render_template('{{ page.title }}', 'page' => templatized, 'content_instance' => content_instance).should == 'Locomotive rocks !'
    end

  end

  describe 'meta_keywords' do
    subject { render_template('{{ home.meta_keywords }}') }
    it { should == @home.meta_keywords }
  end

  describe 'meta_description' do
    subject { render_template('{{ home.meta_description }}') }
    it { should == @home.meta_description }
  end

  def render_template(template = '', assigns = {})
    assigns = {
      'home' => @home
    }.merge(assigns)

    Liquid::Template.parse(template).render assigns
  end

end
