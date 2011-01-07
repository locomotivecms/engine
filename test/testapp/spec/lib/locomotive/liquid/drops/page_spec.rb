require 'spec_helper'

describe Locomotive::Liquid::Drops::Page do

  before(:each) do
    @home = Factory.build(:page)
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

  context '#rendering' do

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

  def render_template(template = '', assigns = {})
    assigns = {
      'home' => @home
    }.merge(assigns)

    Liquid::Template.parse(template).render assigns
  end

end
