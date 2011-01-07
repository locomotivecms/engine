require 'spec_helper'

describe 'Locomotive rendering system' do

  before(:each) do
    @controller = Locomotive::TestController.new
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @site = Factory.build(:site)
    Site.stubs(:find).returns(@site)
    @controller.current_site = @site
    @page = Factory.build(:page, :site => nil, :published => true)
  end

  context 'setting the response' do

    before(:each) do
      @controller.instance_variable_set(:@page, @page)
      @controller.send(:prepare_and_set_response, 'Hello world !')
    end

    it 'sets the content type to html' do
      @controller.response.headers['Content-Type'].should == 'text/html; charset=utf-8'
    end

    it 'displays the output' do
      @controller.output.should == 'Hello world !'
    end

    it 'does not set the cache' do
      @controller.response.headers['Cache-Control'].should be_nil
    end

    it 'sets the cache by simply using etag' do
      @page.cache_strategy = 'simple'
      @page.stubs(:updated_at).returns(Time.now)
      @controller.send(:prepare_and_set_response, 'Hello world !')
      @controller.response.to_a # force to build headers
      @controller.response.headers['Cache-Control'].should == 'public'
    end

    it 'sets the cache for Varnish' do
      @page.cache_strategy = '3600'
      @page.stubs(:updated_at).returns(Time.now)
      @controller.send(:prepare_and_set_response, 'Hello world !')
      @controller.response.to_a # force to build headers
      @controller.response.headers['Cache-Control'].should == 'max-age=3600, public'
    end

  end

  context 'when retrieving page' do

    it 'should retrieve the index page /' do
      @controller.request.fullpath = '/'
      @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{index} }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should also retrieve the index page (index.html)' do
      @controller.request.fullpath = '/index.html'
      @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{index} }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should retrieve it based on the full path' do
      @controller.request.fullpath = '/about_us/team.html'
      @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{about_us/team about_us/content_type_template} }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should return the 404 page if the page does not exist' do
      @controller.request.fullpath = '/contact'
      (klass = Page).expects(:published).returns([true])
      @controller.current_site.pages.expects(:not_found).returns(klass)
      @controller.send(:locomotive_page).should be_true
    end

    context 'templatized page' do

      before(:each) do
        @content_type = Factory.build(:content_type, :site => nil)
        @content = @content_type.contents.build(:_visible => true)
        @page.templatized = true
        @page.content_type = @content_type
        @controller.request.fullpath = '/projects/edeneo.html'
        @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{projects/edeneo projects/content_type_template} }).returns([@page])
      end

      it 'sets the content_instance variable' do
        @content_type.contents.stubs(:where).returns([@content])
        @controller.send(:locomotive_page).should_not be_nil
        @controller.instance_variable_get(:@content_instance).should == @content
      end

      it 'returns the 404 page if the instance does not exist' do
        @content_type.contents.stubs(:where).returns([])
        (klass = Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
        @controller.instance_variable_get(:@content_instance).should be_nil
      end

      it 'returns the 404 page if the instance is not visible' do
        @content._visible = false
        @content_type.contents.stubs(:where).returns([@content])
        (klass = Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
      end

    end

    context 'non published page' do

      before(:each) do
        @page.published = false
        @controller.current_admin = nil
      end

      it 'should return the 404 page if the page has not been published yet' do
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{contact content_type_template} }).returns([@page])
        (klass = Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
      end

      it 'should not return the 404 page if the page has not been published yet and admin is logged in' do
        @controller.current_admin = true
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{contact content_type_template} }).returns([@page])
        @controller.send(:locomotive_page).should == @page
      end

    end

  end

end
