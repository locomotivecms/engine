require 'spec_helper'

describe Locomotive::Liquid::Tags::Nav do

  before(:each) do
    @home = Factory.build(:page)
    home_children = [
      Page.new(:title => 'Child #1', :fullpath => 'child_1', :slug => 'child_1', :published => true),
      Page.new(:title => 'Child #2', :fullpath => 'child_2', :slug => 'child_2', :published => true)
    ]
    @home.stubs(:children_with_minimal_attributes).returns(home_children)
    @home.stubs(:children).returns(home_children)

    other_children = [
      Page.new(:title => 'Child #2.1', :fullpath => 'child_2/sub_child_1', :slug => 'sub_child_1', :published => true),
      Page.new(:title => 'Child #2.2', :fullpath => 'child_2/sub_child_2', :slug => 'sub_child_2', :published => true)
      ]
    @home.children.last.stubs(:children_with_minimal_attributes).returns(other_children)
    @home.children.last.stubs(:children).returns(other_children)

    pages = [@home]
    pages.stubs(:root).returns(pages)
    pages.stubs(:minimal_attributes).returns(pages) # iso
    @site = Factory.build(:site)
    @site.stubs(:pages).returns(pages)
  end

  context '#rendering' do

    it 'renders from site' do
      render_nav.should == '<ul id="nav"><li id="child-1" class="link first"><a href="/child_1">Child #1</a></li><li id="child-2" class="link last"><a href="/child_2">Child #2</a></li></ul>'
    end

    it 'renders from page' do
      render_nav('page').should == '<ul id="nav"><li id="child-1" class="link first"><a href="/child_1">Child #1</a></li><li id="child-2" class="link last"><a href="/child_2">Child #2</a></li></ul>'
    end

    it 'renders from parent' do
      (page = @home.children.last.children.first).stubs(:parent).returns(@home.children.last)
      output = render_nav 'parent', { :page => page }
      output.should == '<ul id="nav"><li id="sub-child-1" class="link on first"><a href="/child_2/sub_child_1">Child #2.1</a></li><li id="sub-child-2" class="link last"><a href="/child_2/sub_child_2">Child #2.2</a></li></ul>'
    end

    it 'adds an icon before the link' do
      render_nav('site', {}, 'icon: true').should match /<li id="child-1" class="link first"><a href="\/child_1"><span><\/span>Child #1<\/a>/
      render_nav('site', {}, 'icon: before').should match /<li id="child-1" class="link first"><a href="\/child_1"><span><\/span>Child #1<\/a>/
    end

    it 'adds an icon after the link' do
      render_nav('site', {}, 'icon: after').should match /<li id="child-1" class="link first"><a href="\/child_1">Child #1<span><\/span><\/a><\/li>/
    end

    it 'assign a different dom id' do
      render_nav('site', {}, 'id: "main-nav"').should match /<ul id="main-nav">/
    end

    it 'excludes entries based on a regexp' do
      render_nav('page', {}, 'exclude: "child_1"').should == '<ul id="nav"><li id="child-2" class="link first last"><a href="/child_2">Child #2</a></li></ul>'
    end

    it 'does not render the parent ul' do
      render_nav('site', {}, 'no_wrapper: true').should_not match /<ul id="nav">/
    end

  end

  def render_nav(source = 'site', registers = {}, template_option = '')
    registers = { :site => @site, :page => @home }.merge(registers)
    liquid_context = ::Liquid::Context.new({}, {}, registers)

    output = Liquid::Template.parse("{% nav #{source} #{template_option} %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end

end
