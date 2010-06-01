require 'spec_helper'
 
describe 'Locomotive rendering system' do
  
  before(:each) do  
    @controller = Locomotive::TestController.new
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @site = Factory.build(:site)
    Site.stubs(:find).returns(@site)
    @controller.current_site = @site
  end

  context 'setting the response' do
    
    before(:each) do
      @controller.send(:prepare_and_set_response, 'Hello world !')
    end
    
    it 'should have a html content type' do
      @controller.response.headers["Content-Type"].should == 'text/html; charset=utf-8'
    end
    
    it 'should display the output' do
      @controller.output.should == 'Hello world !'
    end
  
  end
  
  context 'when retrieving page' do
    
    before(:each) do
      @page = Factory.build(:page, :site => nil, :published => true)
      @controller
    end
    
    it 'should retrieve the index page /' do
      @controller.request.fullpath = '/'
      @controller.current_site.pages.expects(:where).with({ :fullpath => 'index' }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end
    
    it 'should also retrieve the index page (index.html)' do
      @controller.request.fullpath = '/index.html'
      @controller.current_site.pages.expects(:where).with({ :fullpath => 'index' }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end
    
    it 'should retrieve it based on the full path' do
      @controller.request.fullpath = '/about_us/team.html'
      @controller.current_site.pages.expects(:where).with({ :fullpath => 'about_us/team' }).returns([@page])
      @controller.send(:locomotive_page).should_not be_nil
    end
    
    it 'should return the 404 page if the page does not exist' do
      @controller.request.fullpath = '/contact'
      @controller.current_site.pages.expects(:not_found).returns([true])
      @controller.send(:locomotive_page).should be_true
    end
    
    context 'non published page' do
      
      before(:each) do
        @page.published = false
        @controller.current_account = nil
      end
    
      it 'should return the 404 page if the page has not been published yet' do
        @controller.request.fullpath = '/contact'        
        @controller.current_site.pages.expects(:where).with({ :fullpath => 'contact' }).returns([@page])
        @controller.current_site.pages.expects(:not_found).returns([true])
        @controller.send(:locomotive_page).should be_true
      end
      
      it 'should not return the 404 page if the page has not been published yet and admin is logged in' do
        @controller.current_account = true
        @controller.request.fullpath = '/contact'
        @controller.current_site.pages.expects(:where).with({ :fullpath => 'contact' }).returns([@page])
        @controller.send(:locomotive_page).should == @page
      end
      
    end
    
  end
  
end