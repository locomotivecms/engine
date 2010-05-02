require 'spec_helper'
 
describe Page do
  
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
      
    it 'should add the body part' do
      page = Factory(:page)
      page.parts.should_not be_empty
      page.parts.first.name.should == 'body'
    end
    
    it 'should have normalized slug' do
      page = Factory.build(:page, :slug => ' Valid  ité.html ')
      page.valid?
      page.slug.should == 'Valid_ite'
      
      page = Factory.build(:page, :title => ' Valid  ité.html ', :slug => nil, :site => page.site)
      page.should be_valid
      page.slug.should == 'Valid_ite'
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
    
    it 'should generate a route / url from parents' do
      @home.route.should == 'index'
      @home.url.should == 'http://acme.example.com/index.html'
      
      @child_1.route.should == 'foo'
      @child_1.url.should == 'http://acme.example.com/foo.html'
      
      nested_page = Factory(:page, :title => 'Sub sub page 1', :slug => 'bar', :parent => @child_1, :site => @home.site)
      nested_page.route.should == 'foo/bar'
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
      
end