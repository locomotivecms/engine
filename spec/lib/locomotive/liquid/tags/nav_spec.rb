require 'spec_helper'
 
describe Locomotive::Liquid::Tags::Nav do
  
  before(:each) do
    @home = Factory.build(:page)
    @home.stubs(:children).returns([
      Page.new(:title => 'Child #1', :fullpath => 'child_1', :slug => 'child_1'), 
      Page.new(:title => 'Child #2', :fullpath => 'child_2', :slug => 'child_2')
      ])
    @home.children.last.stubs(:children).returns([
      Page.new(:title => 'Child #2.1', :fullpath => 'child_2/sub_child_1', :slug => 'sub_child_1'),
      Page.new(:title => 'Child #2.2', :fullpath => 'child_2/sub_child_2', :slug => 'sub_child_2')
      ])
    @site = Factory.build(:site)
    @site.stubs(:pages).returns([@home])
  end
  
  context '#rendering' do

    it 'renders from site' do
      render_nav.should == '<ul id="nav"><li id="child-1" class="link"><a href="/child_1">Child #1</a></li><li id="child-2" class="link"><a href="/child_2">Child #2</a></li></ul>'
    end
    
    it 'renders from page' do
      (page = @home.children.last.children.first).stubs(:parent).returns(@home.children.last)
      output = render_nav 'page', { :page => page }
      output.should == '<ul id="nav"><li id="sub-child-1" class="link on"><a href="/child_2/sub_child_1">Child #2.1</a></li><li id="sub-child-2" class="link"><a href="/child_2/sub_child_2">Child #2.2</a></li></ul>'
    end
    
  end
  
  def render_nav(source = 'site', registers = {})
    registers = { :site => @site, :page => @home }.merge(registers)
    liquid_context = ::Liquid::Context.new({}, registers)
    
    output = Liquid::Template.parse("{% nav #{source} %}").render(liquid_context)
    output.gsub(/\n\s{0,}/, '')
  end
    
end