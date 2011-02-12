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
      Page.new(:title => 'Child #2.2', :fullpath => 'child_2/sub_child_2', :slug => 'sub_child_2', :published => true),
      Page.new(:title => 'Unpublished #2.2', :fullpath => 'child_2/sub_child_unpublishd_2', :slug => 'sub_child_unpublished_2', :published => false),
      Page.new(:title => 'Templatized #2.3', :fullpath => 'child_2/sub_child_template_3',   :slug => 'sub_child_template_3',    :published => true,   :templatized => true),
      Page.new(:title => 'Unlisted    #2.4', :fullpath => 'child_2/sub_child_unlisted_4',   :slug => 'sub_child_unlisted_4',    :published => true,   :listed => false)
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
    
    it 'renders children to depth' do
      output = render_nav('site', {}, 'depth: 2')
      
      output.should match /<ul id="nav">/
      output.should match /<li id="child-1" class="link first">/
      output.should match /<\/a><ul id="nav-child-2">/
      output.should match /<li id="sub-child-1" class="link first">/
      output.should match /<li id="sub-child-2" class="link last">/
      output.should match /<\/a><\/li><\/ul><\/li><\/ul>/
    end
    
    it 'does not render templatized pages' do
      output = render_nav('site', {}, 'depth: 2')
      
      output.should_not match /sub-child-template-3/
    end
    
    it 'does not render unpublished pages' do
      output = render_nav('site', {}, 'depth: 2')
      
      output.should_not match /sub-child-unpublished-3/
    end
    
    it 'does not render unlisted pages' do
      output = render_nav('site', {}, 'depth: 2')
      
      output.should_not match /sub-child-unlisted-3/
    end
    
    it 'does not render nested excluded pages' do
      output = render_nav('site', {}, 'depth: 2, exclude: "child_2/sub_child_2"')
      
      output.should     match /<li id="child-2" class="link last">/
      output.should     match /<li id="sub-child-1" class="link first last">/
      output.should_not match /sub-child-2/
      
      output = render_nav('site', {}, 'depth: 2, exclude: "child_2"')
      
      output.should     match /<li id="child-1" class="link first last">/
      output.should_not match /child-2/
      output.should_not match /sub-child/
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
