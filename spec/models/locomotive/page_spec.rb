# coding: utf-8

require 'spec_helper'

describe Locomotive::Page do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    Locomotive::Page.any_instance.stubs(:set_default_raw_template).returns(true)
  end

  it 'should have a valid factory' do
    FactoryGirl.build(:page).should be_valid
  end

  describe 'validation' do

    %w{site title}.each do |field|
      it "requires the presence of the #{field}" do
        page = FactoryGirl.build(:page, field.to_sym => nil)
        page.should_not be_valid
        page.errors[field.to_sym].should == ["can't be blank"]
      end
    end

    it 'requires the presence of the slug' do
      page = FactoryGirl.build(:page, :title => nil, :slug => nil)
      page.should_not be_valid
      page.errors[:slug].should == ["can't be blank"]
    end

    it 'requires the uniqueness of the slug' do
      page = FactoryGirl.create(:page)
      another_page = FactoryGirl.build(:page, :site => page.site)
      another_page.should_not be_valid
      another_page.errors[:slug].should == ["is already taken"]
    end

    it 'requires the uniqueness of the handle' do
      page = FactoryGirl.create(:page, :handle => 'foo')
      another_page = FactoryGirl.build(:page, :handle => 'foo', :site => page.site)
      another_page.should_not be_valid
      another_page.errors[:handle].should == ["is already taken"]
    end

    it 'requires the uniqueness of the slug within a "folder"' do
      site = FactoryGirl.create(:site)
      root = FactoryGirl.create(:page, :slug => 'index', :site => site)
      child_1 = FactoryGirl.create(:page, :slug => 'first_child', :parent => root, :site => site)
      (page = FactoryGirl.build(:page, :slug => 'first_child', :parent => root, :site => site)).should_not be_valid
      page.errors[:slug].should == ["is already taken"]

      page.slug = 'index'
      page.valid?.should be_true
    end

    %w{admin locomotive stylesheets images javascripts}.each do |slug|
      it "considers '#{slug}' as an invalid slug" do
        page = FactoryGirl.build(:page, :slug => slug)
        page.stubs(:depth).returns(1)
        page.should_not be_valid
        page.errors[:slug].should == ["is reserved"]
      end
    end

    context '#i18n' do

      before(:each) do
        ::Mongoid::Fields::I18n.locale = 'en'
        @page = FactoryGirl.build(:page, :title => 'Hello world')
        ::Mongoid::Fields::I18n.locale = 'fr'
      end

      after(:all) do
        ::Mongoid::Fields::I18n.locale = 'en'
      end

      it 'requires the presence of the title' do
        @page.title = ''
        @page.valid?.should be_false
        @page.errors[:title].should == ["can't be blank"]
      end

      it 'tells if a page has been translated or not' do
        @page.translated?.should be_false
        @page.title = 'Hello world'
        @page.translated?.should be_true
      end

    end

  end

  # Named scopes ##

  # Associations ##

  # Methods ##

  describe 'once created' do

    it 'should tell if the page is the index one' do
      FactoryGirl.build(:page, :slug => 'index', :site => nil).index?.should be_true
      page = FactoryGirl.build(:page, :slug => 'index', :site => nil)
      page.stubs(:depth).returns(1)
      page.index?.should be_false
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
      }.should_not change(Locomotive::Page, :count)
    end

    it 'does not delete the 404 page' do
      @page.stubs(:not_found?).returns(true)
      lambda {
        @page.destroy.should be_false
        @page.errors.first == 'You can not remove index or 404 pages'
      }.should_not change(Locomotive::Page, :count)
    end

  end

  describe 'tree organization' do

    before(:each) do
      @home     = FactoryGirl.create(:page)
      @child_1  = FactoryGirl.create(:page, :title => 'Subpage 1', :slug => 'foo', :parent_id => @home._id, :site => @home.site)
    end

    it 'adds root elements' do
      page_404 = FactoryGirl.create(:page, :title => 'Page not found', :slug => '404', :site => @home.site)
      Locomotive::Page.roots.count.should == 2
      Locomotive::Page.roots.should == [@home, page_404]
    end

    it 'adds sub pages' do
      child_2 = FactoryGirl.create(:page, :title => 'Subpage 2', :slug => 'bar', :parent => @home, :site => @home.site)
      @home = Locomotive::Page.find(@home.id)
      @home.children.count.should == 2
      @home.children.should == [@child_1, child_2]
    end

    it 'moves its children accordingly' do
      sub_child_1 = FactoryGirl.create(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent => @child_1, :site => @home.site)
      archives    = FactoryGirl.create(:page, :title => 'archives', :slug => 'archives', :parent => @home, :site => @home.site)
      posts       = FactoryGirl.create(:page, :title => 'posts', :slug => 'posts', :parent => archives, :site => @home.site)

      @child_1.parent = archives
      @child_1.save

      @home.reload.children.count.should == 1

      archives.reload.children.count.should == 2
      archives.children.last.depth.should == 2
      archives.children.last.children.first.depth.should == 3
    end

    it 'destroys descendants as well' do
      FactoryGirl.create(:page, :title => 'Sub Subpage 1', :slug => 'bar', :parent_id => @child_1._id, :site => @home.site)
      @child_1.destroy
      Locomotive::Page.where(:slug => 'bar').first.should be_nil
    end

    it 'is scoped by the site' do
      another_home = FactoryGirl.create(:page, :site => FactoryGirl.create('another site'))
      another_home.position.should == 0
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
      [@child_1, @child_2, @child_3].each_with_index { |c, i| c.position.should == i }
    end

    it 'should have its position updated if a sibling is removed' do
      @child_2.destroy
      [@child_1, @child_3.reload].each_with_index { |c, i| c.position.should == i }
    end

  end

  describe 'render module' do

    context '#path combinations' do

      it 'generates them for a path depth equals to 1' do
        Locomotive::Page.path_combinations('foo').should == ['foo', 'content_type_template']
      end

      it 'generates them for a path depth equals to 2' do
        Locomotive::Page.path_combinations('foo/bar').should == ['foo/bar', 'foo/content_type_template', 'content_type_template/bar']
      end

      it 'generates them for a path depth equals to 3' do
        Locomotive::Page.path_combinations('foo/bar/baz').should == ['foo/bar/baz', 'foo/bar/content_type_template', 'foo/content_type_template/baz', 'content_type_template/bar/baz']
      end

    end

  end

  describe 'templatized extension' do

    before(:each) do
      @page = FactoryGirl.build(:page, :parent => FactoryGirl.build(:page, :templatized => false), :templatized => true, :target_klass_name => 'Foo')
    end

    it 'is considered as a templatized page' do
      @page.templatized?.should be_true
    end

    it 'fills in the slug field' do
      @page.valid?
      @page.slug.should == 'content_type_template'
    end

    it 'returns the target klass' do
      @page.target_klass.should == Foo
    end

    it 'has a name for the target entry' do
      @page.target_entry_name.should == 'foo'
    end

    it 'uses the find_by_permalink method when fetching the entry' do
      Foo.expects(:find_by_permalink)
      @page.fetch_target_entry('foo')
    end

    context '#descendants' do

      before(:each) do
        @home = FactoryGirl.create(:page)
        @page.attributes = { :parent_id => @home._id, :site => @home.site }; @page.save!
        @sub_page = FactoryGirl.build(:page, :title => 'Subpage', :slug => 'foo', :parent => @page, :site => @home.site, :templatized => false)
      end

      it 'inherits the templatized property from its parent' do
        @sub_page.valid?
        @sub_page.templatized?.should be_true
        @sub_page.templatized_from_parent?.should be_true
        @sub_page.target_klass_name.should == 'Foo'
      end

      it 'gets templatized if its parent is' do
        @page.attributes = { :templatized => false, :target_klass_name => nil }; @page.save!
        @sub_page.save.should be_true
        @sub_page.templatized?.should be_false

        @page.attributes = { :templatized => true, :target_klass_name => 'Foo' }; @page.save!
        @sub_page.reload
        @sub_page.templatized?.should be_true
        @sub_page.templatized_from_parent?.should be_true
        @sub_page.target_klass_name.should == 'Foo'
      end

      it 'is not templatized if its parent is no more a templatized page' do
        @sub_page.save.should be_true
        @page.templatized = false; @page.save!
        @sub_page.reload
        @sub_page.templatized.should be_false
        @sub_page.templatized_from_parent.should be_false
        @sub_page.target_klass_name.should be_nil
      end

    end

    context 'using a content type' do

      before(:each) do
        @site = FactoryGirl.build(:site)
        @content_type = FactoryGirl.build(:content_type, :slug => 'posts', :site => @site)
        @page.site = @site
        @page.target_klass_name = 'Locomotive::Entry42'
      end

      it 'has a name for the target entry' do
        @site.stubs(:content_types).returns(mock(:find => @content_type))
        @page.target_entry_name.should == 'post'
      end

      it 'returns the slug of the target klass' do
        @site.stubs(:content_types).returns(mock(:find => @content_type))
        @page.target_klass_slug.should == 'posts'
      end

      context '#security' do

        before(:each) do
          Locomotive::ContentType.stubs(:find).returns(@content_type)
        end

        it 'is valid if the content type belongs to the site' do
          @page.send(:ensure_target_klass_name_security)
          @page.errors.should be_empty
        end

        it 'does not valid the page if the content type does not belong to the site' do
          @content_type.site = FactoryGirl.build(:site)
          @page.send(:ensure_target_klass_name_security)
          @page.errors[:target_klass_name].should == ['presents a security problem']
        end

      end

    end

  end

  describe 'listed extension' do

    it 'is considered as a visible page' do
      @page = FactoryGirl.build(:page, :site => nil)
      @page.listed?.should be_true
    end

    it 'is not considered as a visible page' do
      @page = FactoryGirl.build(:page, :site => nil, :listed => false)
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

  describe 'response type' do

    before(:each) do
      @page = FactoryGirl.build(:page, :site => nil)
    end

    it 'is a HTML document by default' do
      @page.response_type.should == 'text/html'
      @page.default_response_type?.should be_true
    end

    it 'can also be a JSON document' do
      @page.response_type = 'application/json'
      @page.default_response_type?.should be_false
    end

  end

  class Foo
  end

  class Locomotive::Entry42
  end

  def fake_bson_id(id)
    BSON::ObjectId(id.to_s.rjust(24, '0'))
  end

end
