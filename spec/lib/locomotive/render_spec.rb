require 'spec_helper'
require 'ostruct'

describe 'Locomotive rendering system' do

  before(:each) do
    @controller = Locomotive::TestController.new
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    @site = FactoryGirl.build(:site)
    Locomotive::Site.stubs(:find).returns(@site)
    @controller.current_site = @site
    @page = FactoryGirl.build(:page, site: nil, published: true)
  end

  context '#liquid_context' do

    before(:each) do
      @controller.instance_variable_set(:@page, @page)
      @controller.stubs(:flash).returns({})
      @controller.stubs(:params).returns({})
      @controller.stubs(:request).returns(OpenStruct.new(url: '/'))
    end

    it 'includes the current date and time' do
      context = @controller.send(:locomotive_context)
      context['now'].should_not be_blank
      context['today'].should_not be_blank
    end

    it 'includes the locale' do
      context = @controller.send(:locomotive_context)
      context['locale'].should == 'en'
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

    it 'sets the content type to the one specified by the page' do
      @page.response_type = 'application/json'
      @controller.send(:prepare_and_set_response, 'Hello world !')
      @controller.response.headers['Content-Type'].should == 'application/json; charset=utf-8'
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
      @page.stubs(:updated_at).returns(Time.zone.now)
      @controller.send(:prepare_and_set_response, 'Hello world !')
      @controller.response.to_a # force to build headers
      @controller.response.headers['Cache-Control'].should == 'public'
    end

    it 'sets the cache for Varnish' do
      @page.cache_strategy = '3600'
      @page.stubs(:updated_at).returns(Time.zone.now)
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
      @controller.current_site.pages.expects(:where).with(depth: 0, :fullpath.in => %w{index}).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should also retrieve the index page (index.html)' do
      @controller.request.fullpath = '/index.html'
      @controller.current_site.pages.expects(:where).with(depth: 0, :fullpath.in => %w{index}).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should retrieve it based on the full path' do
      @controller.request.fullpath = '/about_us/team.html'
      @controller.current_site.pages.expects(:where).with(depth: 2, :fullpath.in => %w{about_us/team about_us/content_type_template content_type_template/team}).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'does not include the query string' do
      @controller.request.fullpath = '/about_us/team.html?some=params&we=use'
      @controller.current_site.pages.expects(:where).with(depth: 2, :fullpath.in => %w{about_us/team about_us/content_type_template content_type_template/team}).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end

    it 'should return the 404 page if the page does not exist' do
      @controller.request.fullpath = '/contact'
      (klass = Locomotive::Page).expects(:published).returns([true])
      @controller.current_site.pages.expects(:not_found).returns(klass)
      @controller.send(:locomotive_page).should be_true
    end

    context 'redirect' do

      before(:each) do
        @page.redirect = true
        @page.redirect_url = 'http://www.example.com/'
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:where).with(depth: 1, :fullpath.in => %w{contact content_type_template}).returns([@page])
      end

      (301..302).each do |status|
        it "redirects to the redirect_url with a #{status} status" do
          @page.redirect_type = status
          @controller.expects(:redirect_to).with('http://www.example.com/', { status: status }).returns(true)
          @controller.send(:render_locomotive_page)
        end
      end

      it 'redirects to the redirect_url in the editing version if specified' do
        @page.redirect_url = '/another_page'
        @controller.stubs(:editing_page?).returns(true)
        @controller.expects(:redirect_to).with('/another_page/_edit', { status: 301 }).returns(true)
        @controller.send(:render_locomotive_page)
      end

    end

    context 'templatized page' do

      before(:each) do
        @content_type = FactoryGirl.build(:content_type, site: nil)
        @content_entry = @content_type.entries.build(_visible: true)
        @page.templatized = true
        @page.stubs(:fetch_target_entry).returns(@content_entry)
        @page.stubs(:fullpath).returns('/projects/content_type_template')
        @controller.request.fullpath = '/projects/edeneo.html'
        @controller.current_site.pages.expects(:where).with(depth: 2, :fullpath.in => %w{projects/edeneo projects/content_type_template content_type_template/edeneo}).returns([@page])
      end

      it 'sets the content_entry variable' do
        page = @controller.send(:locomotive_page)
        page.should_not be_nil
        page.content_entry.should == @content_entry
      end

      it 'returns the 404 page if the instance does not exist' do
        @page.stubs(:fetch_target_entry).returns(nil)
        (klass = Locomotive::Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
      end

      it 'returns the 404 page if the instance is not visible' do
        @content_entry._visible = false
        @page.stubs(:fetch_target_entry).returns(@content_entry)
        (klass = Locomotive::Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
      end

    end

    context 'non published page' do

      before(:each) do
        @page.published = false
        @controller.current_locomotive_account = nil
      end

      it 'should return the 404 page if the page has not been published yet' do
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:where).with(depth: 1, :fullpath.in => %w{contact content_type_template}).returns([@page])
        (klass = Locomotive::Page).expects(:published).returns([true])
        @controller.current_site.pages.expects(:not_found).returns(klass)
        @controller.send(:locomotive_page).should be_true
      end

      it 'should not return the 404 page if the page has not been published yet and admin is logged in' do
        @controller.current_locomotive_account = true
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:where).with(depth: 1, :fullpath.in => %w{contact content_type_template}).returns([@page])
        @controller.send(:locomotive_page).should == @page
      end

    end

  end
end
