require 'spec_helper'
require 'ostruct'

describe 'Locomotive rendering system' do

  before(:each) do
    @controller = Locomotive::TestController.new
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @site = FactoryGirl.build(:site)
    Site.stubs(:find).returns(@site)
    @controller.current_site = @site
    @page = FactoryGirl.build(:page, :site => nil, :published => true)
  end

  context '#liquid_context' do

    it 'includes the current date and time' do
      @controller.instance_variable_set(:@page, @page)
      @controller.stubs(:flash).returns({})
      @controller.stubs(:params).returns({})
      @controller.stubs(:request).returns(OpenStruct.new(:url => '/'))
      context = @controller.send(:locomotive_context)
      context['now'].should_not be_blank
      context['today'].should_not be_blank
    end

  end

  context 'setting the response' do

    before(:each) do
      @controller.instance_variable_set(:@page, @page)
      @controller.send(:prepare_and_set_response, 'Hello world !')
    end

    it 'sets the content type to html' do
      @controller.response.headers['Content-Type'].should == 'text/html; charset=utf-8'
    end

    it 'sets the status to 200 OK' do
      @controller.status.should == :ok
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

    it 'sets the status to 404 not found when no page is found' do
      @page.stubs(:not_found?).returns(true)
      @controller.send(:prepare_and_set_response, 'Hello world !')
      @controller.status.should == :not_found
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

    it 'does not include the query string' do
      @controller.request.fullpath = '/about_us/team.html?some=params&we=use'
      @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{about_us/team about_us/content_type_template} }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should return the 404 page if the page does not exist' do
      @controller.request.fullpath = '/contact'
      (klass = Page).expects(:published).returns([true])
      @controller.current_site.pages.expects(:not_found).returns(klass)
      @controller.send(:locomotive_page).should be_true
    end

    context 'redirect' do

      before(:each) do
        @page.redirect = true
        @page.redirect_url = 'http://www.example.com/'
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:any_in).with({ :fullpath => %w{contact content_type_template} }).returns([@page])
      end

      it 'redirects to the redirect_url' do
        @controller.expects(:redirect_to).with('http://www.example.com/').returns(true)
        @controller.send(:render_locomotive_page)
      end

    end

    context 'templatized page' do

      before(:each) do
        @content_type = FactoryGirl.build(:content_type, :site => nil)
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

  after(:all) do
    ENV['APP_TLD'] = nil
    Locomotive.configure_for_test(true)
  end

end
