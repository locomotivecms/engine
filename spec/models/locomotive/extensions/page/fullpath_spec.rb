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
        @page.stubs(:ancestors_and_self).returns([FactoryGirl.build(:page), FactoryGirl.build(:page, :slug => 'archives'), FactoryGirl.build(:page, :slug => 'projects'), @page])
        @page.send(:build_fullpath)
        @page.fullpath.should == 'archives/projects/*'
      end

      it 'includes many "*" when there are ancestors enabling wildcards' do
        @page.stubs(:ancestors_and_self).returns([FactoryGirl.build(:page),
          FactoryGirl.build(:page, :slug => 'archives'),
          FactoryGirl.build(:page, :slug => 'month', :wildcard => true),
          FactoryGirl.build(:page, :slug => 'projects'), @page])
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
        Rails.logger.debug "=========== START ============"
        @month_page.update_attributes :wildcard => true
        Rails.logger.debug "=========== END ============"
        @project_page.reload
        @project_page.fullpath.should == 'archives/*/projects/*'
        @posts_page.reload
        @posts_page.fullpath.should == 'archives/*/posts'
      end

      it 'turns off the wildcard property of page' do
        puts "==== 1 ==="
        Rails.logger.debug "==== 1 ==="
        puts "@month_page = #{@month_page.fullpath.inspect} / #{@month_page.wildcards.inspect}"
        @month_page.update_attributes :wildcard => true
        puts "==== 2 === "
        Rails.logger.debug "==== 2 ==="
        @month_page.update_attributes :wildcard => false
        puts "---- DONE ----"
        Rails.logger.debug "==== DONE ==="
        @project_page.reload
        @project_page.fullpath.should == 'archives/month/projects/*'
        @project_page.wildcards.should == %w(project)
        @posts_page.reload
        @posts_page.fullpath.should == 'archives/month/posts'
        @posts_page.wildcards.should == nil
      end

    end

  end

end