# coding: utf-8

require 'spec_helper'

describe Page do

  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    Page.any_instance.stubs(:set_default_raw_template).returns(true)
  end

  it 'should have a valid factory' do
    FactoryGirl.build(:page).should be_valid
  end

  # Validations ##

  %w{site title}.each do |field|
    it "should validate presence of #{field}" do
      page = FactoryGirl.build(:page, field.to_sym => nil)
      page.should_not be_valid
      page.errors[field.to_sym].should == ["can't be blank"]
    end
  end

  it 'should validate presence of slug' do
    page = FactoryGirl.build(:page, :title => nil, :slug => nil)
    page.should_not be_valid
    page.errors[:slug].should == ["can't be blank"]
  end

  it 'should validate uniqueness of slug' do
    page = FactoryGirl.create(:page)
    (page = FactoryGirl.build(:page, :site => page.site)).should_not be_valid
    page.errors[:slug].should == ["is already taken"]
  end

  it 'should validate uniqueness of slug within a "folder"' do
    site = FactoryGirl.create(:site)
    root = FactoryGirl.create(:page, :slug => 'index', :site => site)
    child_1 = FactoryGirl.create(:page, :slug => 'first_child', :parent => root, :site => site)
    (page = FactoryGirl.build(:page, :slug => 'first_child', :parent => root, :site => site)).should_not be_valid
    page.errors[:slug].should == ["is already taken"]

    page.slug = 'index'
    page.valid?.should be_true
  end

  %w{admin stylesheets images javascripts}.each do |slug|
    it "should consider '#{slug}' as invalid" do
      page = FactoryGirl.build(:page, :slug => slug)
      page.should_not be_valid
      page.errors[:slug].should == ["is reserved"]
    end
  end

  # Named scopes ##

  # Associations ##

  # Methods ##

  describe 'once created' do

    it 'should tell if the page is the index one' do
      FactoryGirl.build(:page, :slug => 'index', :site => nil).index?.should be_true
      FactoryGirl.build(:page, :slug => 'index', :depth => 1, :site => nil).index?.should be_false
    end

    it 'should have normalized slug' do
      page = FactoryGirl.build(:page, :slug => ' Valid  ité.html ')
      page.valid?
      page.slug.should == 'valid-ite-html'

      page = FactoryGirl.build(:page, :title => ' Valid  ité.html ', :slug => nil, :site => page.site)
      page.should be_valid
      page.slug.should == 'valid-ite-html'
    end

    it 'has no cache strategy' do
      page = FactoryGirl.build(:page, :site => nil)
      page.with_cache?.should == false
    end

  end

  describe '#deleting' do

    before(:each) do
      @page = FactoryGirl.build(:page)
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

  describe 'acts as tree' do

    before(:each) do
      @home = FactoryGirl.create(:page)
      @child_1 = FactoryGirl.create(:page, :title => 'Subpage 1', :slug => 'foo', :parent_id => @home._id, :site => @home.site)
    end

    it 'should add root elements' do
      page_404 = FactoryGirl.create(:page, :title => 'Page not found', :slug => '404', :site => @home.site)
      Page.roots.count.should == 2
      Page.roots.should == [@home, page_404]
    end

    it 'should add sub pages' do
      child_2 = FactoryGirl.create(:page, :title => 'Subpage 2', :slug => 'bar', :parent => @home, :site => @home.site)
      @home = Page.find(@home.id)
      @home.children.count.should == 2
      @home.children.should == [@child_1, child_2]
    end

    it 'should move its children accordingly' do
      sub_child_1 = FactoryGirl.create(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent => @child_1, :site => @home.site)
      archives = FactoryGirl.create(:page, :title => 'archives', :slug => 'archives', :parent => @home, :site => @home.site)
      posts = FactoryGirl.create(:page, :title => 'posts', :slug => 'posts', :parent => archives, :site => @home.site)

      @child_1.parent_id = archives._id
      @child_1.save

      @child_1.position.should == 2
      @home.reload.children.count.should == 1

      archives.reload.children.count.should == 2
      archives.children.last.depth.should == 2
      archives.children.last.position.should == 2
      archives.children.last.children.first.depth.should == 3
    end

    it 'should destroy descendants as well' do
      FactoryGirl.create(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent_id => @child_1._id, :site => @home.site)
      @child_1.destroy
      Page.where(:slug => 'bar').first.should be_nil
    end

  end

  describe 'acts as list' do

    before(:each) do
      @home = FactoryGirl.create(:page)
      @child_1 = FactoryGirl.create(:page, :title => 'Subpage 1', :slug => 'foo', :parent => @home, :site => @home.site)
      @child_2 = FactoryGirl.create(:page, :title => 'Subpage 2', :slug => 'bar', :parent => @home, :site => @home.site)
      @child_3 = FactoryGirl.create(:page, :title => 'Subpage 3', :slug => 'acme', :parent => @home, :site => @home.site)
    end

    it 'should be at the bottom of the folder once created' do
      [@child_1, @child_2, @child_3].each_with_index { |c, i| c.position.should == i + 1 }
    end

    it 'should have its position updated if a sibling is removed' do
      @child_2.destroy
      [@child_1, @child_3.reload].each_with_index { |c, i| c.position.should == i + 1 }
    end

  end

  describe 'templatized extension' do

    before(:each) do
      @page = FactoryGirl.build(:page, :site => nil, :templatized => true, :content_type_id => 42)
      ContentType.stubs(:find).returns(FactoryGirl.build(:content_type, :site => nil))
    end

    it 'is considered as a templatized page' do
      @page.templatized?.should be_true
    end

    it 'fills in the slug field' do
      @page.valid?
      @page.slug.should == 'content_type_template'
    end

    it 'does forget to set the content type id' do
      @page.content_type_id.should == 42
    end

  end

  describe 'listed extension' do

    it 'is considered as a visible page' do
      @page = FactoryGirl.build(:page, :site => nil, :content_type_id => 42)
      @page.listed?.should be_true
    end

    it 'is not considered as a visible page' do
      @page = FactoryGirl.build(:page, :site => nil, :listed => false, :content_type_id => 42)
      @page.listed?.should be_false
    end

  end

  describe 'redirect extension' do

    before(:each) do
      @page = FactoryGirl.build(:page, :site => nil, :redirect=> true, :redirect_url => 'http://www.google.com/')
    end

    it 'is considered as a redirect page' do
      @page.redirect?.should be_true
    end

    it 'validates the redirect_url if redirect is set' do
      @page.redirect_url = nil
      @page.should_not be_valid
      @page.errors[:redirect_url].should == ["can't be blank"]
    end

    it 'should validate format of redirect_url' do
      @page.redirect_url = "invalid url with spaces"
      @page.should_not be_valid
      @page.errors[:redirect_url].should == ["is invalid"]
    end
  end

  after(:all) do
    ENV['APP_TLD'] = nil
    Locomotive.configure_for_test(true)
  end
end
