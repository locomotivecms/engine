require 'spec_helper'
 
describe Page do
  
  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
  end
  
  it 'should have a valid factory' do
    Factory.build(:page).should be_valid
  end
  
  # Validations ##
  
  %w{site title}.each do |field|
    it "should validate presence of #{field}" do
      page = Factory.build(:page, field.to_sym => nil)
      page.should_not be_valid
      page.errors[field.to_sym].should == ["can't be blank"]
    end
  end
  
  it 'should validate presence of slug' do
    page = Factory.build(:page, :title => nil, :slug => nil)
    page.should_not be_valid
    page.errors[:slug].should == ["can't be blank"]
  end
  
  it 'should validate uniqueness of slug' do
    page = Factory(:page)
    (page = Factory.build(:page, :site => page.site)).should_not be_valid
    page.errors[:slug].should == ["is already taken"]
  end
  
  it 'should validate uniqueness of slug within a "folder"' do
    site = Factory(:site)
    root = Factory(:page, :slug => 'index', :site => site)
    child_1 = Factory(:page, :slug => 'first_child', :parent => root, :site => site)
    (page = Factory.build(:page, :slug => 'first_child', :parent => root, :site => site)).should_not be_valid
    page.errors[:slug].should == ["is already taken"]
    
    page.slug = 'index'
    page.valid?.should be_true
  end
  
  %w{admin stylesheets images javascripts}.each do |slug|
    it "should consider '#{slug}' as invalid" do
      page = Factory.build(:page, :slug => slug)
      page.should_not be_valid
      page.errors[:slug].should == ["is reserved"]
    end
  end
  
  # Named scopes ##
  
  # Associations ##
    
  # Methods ##
  
  describe 'once created' do
  
    it 'should tell if the page is the index one' do
      Factory.build(:page, :slug => 'index', :site => nil).index?.should be_true
      Factory.build(:page, :slug => 'index', :depth => 1, :site => nil).index?.should be_false
    end
          
    it 'should have normalized slug' do
      page = Factory.build(:page, :slug => ' Valid  ité.html ')
      page.valid?
      page.slug.should == 'Valid_ite'
      
      page = Factory.build(:page, :title => ' Valid  ité.html ', :slug => nil, :site => page.site)
      page.should be_valid
      page.slug.should == 'Valid_ite'
    end
    
    it 'has no cache strategy' do
      page = Factory.build(:page, :site => nil)
      page.with_cache?.should == false
    end
    
  end
  
  describe '#deleting' do
    
    before(:each) do 
      @page = Factory.build(:page)
    end
    
    it 'does not delete the index page' do
      @page.stubs(:index?).returns(true)
      lambda {
        @page.destroy.should be_false
        @page.errors.first == 'You can not remove index or 404 pages'
      }.should_not change(Page, :count)
    end
    
    it 'does not delete the 404 page' do
      @page.stubs(:not_found?).returns(true)
      lambda {
        @page.destroy.should be_false
        @page.errors.first == 'You can not remove index or 404 pages'
      }.should_not change(Page, :count)
    end
    
  end
  
  describe 'accepts_nested_attributes_for used for parts' do
    
    before(:each) do
      @page = Factory.build(:page)
      @page.parts.build(:name => 'Main content', :slug => 'layout')
      @page.parts.build(:name => 'Left column', :slug => 'left_sidebar')
      @page.parts.build(:name => 'Right column', :slug => 'right_sidebar')
    end
    
    it 'should add parts' do
      attributes = { '0' => { 'slug' => 'footer', 'name' => 'A custom footer', 'value' => 'End of page' } }
      @page.parts_attributes = attributes
      @page.parts.size.should == 4
      @page.parts.last.slug.should == 'footer'
      @page.parts.last.disabled.should == false
    end
    
    it 'should update parts' do
      attributes = { '0' => { 'slug' => 'layout', 'name' => 'A new name', 'value' => 'Hello world' } }
      @page.parts_attributes = attributes
      @page.parts.size.should == 3
      @page.parts.first.slug.should == 'layout'
      @page.parts.first.name.should == 'A new name'
      @page.parts.first.value.should == 'Hello world'
    end
    
    it 'should disable parts' do
      attributes = { '0' => { 'slug' => 'left_sidebar', 'disabled' => 'true' } }
      @page.parts_attributes = attributes
      @page.parts.size.should == 3
      @page.parts.first.disabled.should == true
      @page.parts[1].disabled.should == true
      @page.parts[2].disabled.should == true
    end
    
    it 'should add/update/disable parts at the same time' do
      @page.parts.size.should == 3
      
      attributes = {
        '0' => { 'slug' => 'layout', 'name' => 'Body', 'value' => 'Hello world' },
        '1' => { 'slug' => 'left_sidebar', 'disabled' => 'true' },
        '2' => { 'id' => @page.parts[2].id, 'value' => 'Content from right sidebar', 'disabled' => 'false' }
      }
      @page.parts_attributes = attributes
      @page.parts.size.should == 3
            
      @page.parts[0].value.should == 'Hello world'
      @page.parts[1].disabled.should == true
      @page.parts[2].disabled.should == false    
    end
    
    it 'should update it with success (mongoid bug #71)' do
      @page.save
      @page = Page.first
      
      @page.parts.size.should == 3      
      @page.parts_attributes = { '0' => { 'slug' => 'header', 'name' => 'A custom header', 'value' => 'Head of page' } }
      @page.parts.size.should == 4
      
      @page.save      
      @page = Page.first
      
      @page.parts.size.should == 4
    end
    
  end
  
  describe 'dealing with page parts' do # DUPLICATED ?
    
    before(:each) do
      @page = Factory.build(:page)
      @parts = [
        PagePart.new(:name => 'Main content', :slug => 'layout'),
        PagePart.new(:name => 'Left column', :slug => 'left_sidebar'),
        PagePart.new(:name => 'Right column', :slug => 'right_sidebar')
      ]      
      @page.send(:update_parts, @parts)
    end
        
    it 'should add new parts from an array of parts' do
      @page.parts.size.should == 3
      @page.parts.shift.name.should == 'Main content'
      @page.parts.shift.name.should == 'Left column'
      @page.parts.shift.name.should == 'Right column'
    end
    
    it 'should update parts' do
      @parts[1].name = 'Very left column'
      @page.send(:update_parts, @parts)
      @page.parts.size.should == 3
      @page.parts[1].name.should == 'Very left column'
      @page.parts[1].slug.should == 'left_sidebar'
    end
    
    it 'should disable parts' do
      @parts = [@parts.shift, @parts.pop]
      @page.send(:update_parts, @parts)
      @page.parts.size.should == 3
      @page.parts[1].name.should == 'Left column'
      @page.parts[1].disabled.should be_true
    end
    
    it 'should enable parts previously disabled' do
      parts_at_first = @parts.clone
      @parts = [@parts.shift, @parts.pop]
      @page.send(:update_parts, @parts)
      @page.send(:update_parts, parts_at_first)
      @page.parts.size.should == 3
      @page.parts[1].name.should == 'Left column'
      @page.parts[1].disabled.should be_true
    end
    
  end
  
  describe 'acts as tree' do
    
    before(:each) do
      @home = Factory(:page)      
      @child_1 = Factory(:page, :title => 'Subpage 1', :slug => 'foo', :parent_id => @home._id, :site => @home.site)
    end
    
    it 'should add root elements' do
      page_404 = Factory(:page, :title => 'Page not found', :slug => '404', :site => @home.site)
      Page.roots.count.should == 2
      Page.roots.should == [@home, page_404]
    end
    
    it 'should add sub pages' do
      child_2 = Factory(:page, :title => 'Subpage 2', :slug => 'bar', :parent => @home, :site => @home.site)      
      Page.first.children.count.should == 2
      Page.first.children.should == [@child_1, child_2]
    end
    
    it 'should move its children accordingly' do
      sub_child_1 = Factory(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent => @child_1, :site => @home.site)
      archives = Factory(:page, :title => 'archives', :slug => 'archives', :parent => @home, :site => @home.site)
      posts = Factory(:page, :title => 'posts', :slug => 'posts', :parent => archives, :site => @home.site)
      
      @child_1.parent_id = archives._id
      @child_1.save
      
      @child_1.position.should == 2
      @home.reload.children.count.should == 1
      
      archives.reload.children.count.should == 2
      archives.children.last.depth.should == 2
      archives.children.last.position.should == 2
      archives.children.last.children.first.depth.should == 3
    end
    
    it 'should generate a path / url from parents' do
      @home.fullpath.should == 'index'
      @home.url.should == 'http://acme.example.com/index.html'
      
      @child_1.fullpath.should == 'foo'
      @child_1.url.should == 'http://acme.example.com/foo.html'
      
      nested_page = Factory(:page, :title => 'Sub sub page 1', :slug => 'bar', :parent => @child_1, :site => @home.site)
      nested_page.fullpath.should == 'foo/bar'
      nested_page.url.should == 'http://acme.example.com/foo/bar.html'
    end
    
    it 'should destroy descendants as well' do
      Factory(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent_id => @child_1._id, :site => @home.site)
      @child_1.destroy
      Page.where(:slug => 'bar').first.should be_nil
    end
    
  end
    
  describe 'acts as list' do
     
    before(:each) do
      @home = Factory(:page)
      @child_1 = Factory(:page, :title => 'Subpage 1', :slug => 'foo', :parent => @home, :site => @home.site)
      @child_2 = Factory(:page, :title => 'Subpage 2', :slug => 'bar', :parent => @home, :site => @home.site)  
      @child_3 = Factory(:page, :title => 'Subpage 3', :slug => 'acme', :parent => @home, :site => @home.site)
    end
     
    it 'should be at the bottom of the folder once created' do
      [@child_1, @child_2, @child_3].each_with_index { |c, i| c.position.should == i + 1 }
    end
  
    it 'should have its position updated if a sibling is removed' do
      @child_2.destroy
      [@child_1, @child_3.reload].each_with_index { |c, i| c.position.should == i + 1 }
    end
     
  end
  
  context 'rendering' do
   
    before(:each) do
      @page = Factory.build(:page, :site => nil)      
      @page.parts.build :slug => 'layout', :value => 'Hello world !'
      @page.parts.build :slug => 'left_sidebar', :value => 'A sidebar...'
      @page.send(:store_template)
      @layout = Factory.build(:layout, :site => nil)
      @layout.send(:store_template)
      @context = Liquid::Context.new
    end
   
    context 'without layout' do
       
       it 'should render the body part' do
         @page.render(@context).should == 'Hello world !'
       end
       
    end
    
    context 'with layout' do
      
      it 'should render both the body and sidebar parts' do
        @page.layout = @layout        
        @page.render(@context).should == %{<html>
    <head>
      <title>My website</title>
    </head>
    <body>
      <div id="sidebar">A sidebar...</div>
      <div id="main"><p>Hello world !</p></div>
    </body>
  </html>}
      end
      
    end
    
  end 
end