# coding: utf-8

require 'spec_helper'

describe Locomotive::Page do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    Locomotive::Page.any_instance.stubs(:set_default_raw_template).returns(true)
  end

  describe 'wildcards' do

    before(:each) do
      @page = FactoryGirl.build(:page, :parent => FactoryGirl.build(:page), :title => 'Project template', :slug => 'permalink', :wildcard => true)
    end

    it 'has a fullpath with wildcards' do
      @page.wildcard?.should be_true
    end

    it 'returns a nice output of the fullpath' do
      @page.fullpath  = 'archives/*/projects/*'
      @page.wildcards = %w(month permalink)
      @page.pretty_fullpath.should == 'archives/:month/projects/:permalink'
    end

    it 'compiles a fullpath with wildcards' do
      @page.fullpath  = 'archives/*/projects/*'
      @page.wildcards = %w(month permalink)
      @page.compiled_fullpath('month' => 'june', 'permalink' => 'hello-world').should == 'archives/june/projects/hello-world'
    end

    describe 'building the fullpath' do

      it 'returns "index" for the root page' do
        @page = FactoryGirl.build(:page)
        @page.send(:build_fullpath)
        @page.fullpath.should == 'index'
      end

      it 'returns "404" for the "page not found" page' do
        @page = FactoryGirl.build(:page, :slug => '404')
        @page.send(:build_fullpath)
        @page.fullpath.should == '404'
      end

      it 'includes a single "*" if the page enables wildcards' do
        @page.send(:build_fullpath)
        @page.fullpath.should == '*'
      end

      it 'includes a single "*" if the page enables wildcards and if there are a lot of ancestors' do
        @page.stubs(:parent).returns(FactoryGirl.build(:page, :fullpath => 'archives/projects'))
        @page.send(:build_fullpath)
        @page.fullpath.should == 'archives/projects/*'
      end

      it 'includes many "*" when there are ancestors enabling wildcards' do
        @page.stubs(:parent).returns(FactoryGirl.build(:page, :fullpath => 'archives/*/projects'))
        @page.send(:build_fullpath)
        @page.fullpath.should == 'archives/*/projects/*'
      end

    end

    describe 'adding wildcards' do

      it 'fills the array of wildcards' do
        @page.valid?
        @page.wildcards.should == %w(permalink)
      end

      it 'fills the array of wildcards from ancestors' do
        @page.parent.stubs(:has_wildcards?).returns(true)
        @page.parent.wildcards = %w(category month)
        @page.valid?
        @page.wildcards.should == %w(category month permalink)
      end

      it 'contains a array of valid wildcards' do
        @page.slug = 'another permalink'
        @page.valid?
        @page.wildcards.should == %w(another-permalink)
      end

    end

    describe 'propagating changes' do

      before(:each) do
        @home_page      = FactoryGirl.create(:page)
        @archives_page  = FactoryGirl.create(:page, :site => @home_page.site, :parent => @home_page, :slug => 'archives')
        @month_page     = FactoryGirl.create(:page, :site => @home_page.site, :parent => @archives_page, :slug => 'month')
        @projects_page  = FactoryGirl.create(:page, :site => @home_page.site, :parent => @month_page, :slug => 'projects')
        @project_page   = FactoryGirl.create(:page, :site => @home_page.site, :parent => @projects_page, :slug => 'project', :wildcard => true)
        @posts_page     = FactoryGirl.create(:page, :site => @home_page.site, :parent => @month_page, :slug => 'posts')
      end

      it 'keeps the wildcards as they were if we modify a slug of an ancestor' do
        @archives_page.update_attributes :slug => 'my_archives'
        @project_page.reload
        @project_page.fullpath.should == 'my_archives/month/projects/*'
      end

      it 'turns a page into a wildcards one' do
        @month_page.update_attributes :wildcard => true
        @project_page.reload
        @project_page.fullpath.should == 'archives/*/projects/*'
        @posts_page.reload
        @posts_page.fullpath.should == 'archives/*/posts'
      end

      it 'turns off the wildcard property of page' do
        @month_page.update_attributes :wildcard => true
        @month_page.update_attributes :wildcard => false
        @project_page.reload
        @project_page.fullpath.should == 'archives/month/projects/*'
        @project_page.wildcards.should == %w(project)
        @posts_page.reload
        @posts_page.fullpath.should == 'archives/month/posts'
        @posts_page.wildcards.should == []
      end

    end

    describe 'building the hash map asssociating a wildcard name with its value from a path' do

      it 'returns an empty map for non wildcards fullpath' do
        @page.fullpath  = 'index'
        @page.wildcards = nil
        @page.match_wildcards('index').should be_empty
      end

      it 'underscores the wildcard name in the returned hash map' do
        @page.fullpath  = 'projects/*'
        @page.wildcards = %w(my-permalink)
        @page.match_wildcards('projects/hello-world').should == { 'my_permalink' => 'hello-world' }
      end

      it 'returns a map with one element if the fullpath contains a single wildcard' do
        @page.fullpath  = 'projects/*'
        @page.wildcards = %w(permalink)
        @page.match_wildcards('projects/hello-world').should == { 'permalink' => 'hello-world' }
      end

      it 'returns a map with as many elements as there are wildcards in the fullpath' do
        @page.fullpath  = 'archives/*/projects/*'
        @page.wildcards = %w(month permalink)
        @page.match_wildcards('archives/june/projects/hello-world').should == {
          'month'     => 'june',
          'permalink' => 'hello-world'
        }
      end

      it 'stores the map inside a virtual attribute' do
        @page.fullpath  = 'projects/*'
        @page.wildcards = %w(permalink)
        @page.match_wildcards('projects/hello-world')
        @page.wildcards_hash.should == { 'permalink' => 'hello-world' }
      end

    end

  end

end