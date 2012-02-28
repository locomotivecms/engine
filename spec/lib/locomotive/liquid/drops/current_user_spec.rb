require 'spec_helper'

describe Locomotive::Liquid::Drops::CurrentUser do

  before(:each) do
    @page = FactoryGirl.build(:sub_page)

    @site = @page.site
    @site.pages.expects(:any_in).returns([@page])

    @controller = Locomotive::TestController.new
    @controller.stubs(:flash).returns(ActionDispatch::Flash::FlashHash.new())
    @controller.stubs(:params).returns(:url => '/subpage')
    @controller.stubs(:request).returns(OpenStruct.new(:url => '/subpage', :fullpath => '/subpage'))
    @controller.current_site = @site
  end
  context '#logged_in?' do
    it 'returns false  when no user is logged in' do
      @page.raw_template = '{{ current_user.logged_in? }}'
      @page.send(:serialize_template)
      @controller.expects(:render).with(:text => "false", :layout => false, :status => :ok).returns(true)
      @controller.send(:render_locomotive_page)
    end
  end


  after(:all) do
    ENV['APP_TLD'] = nil
    Locomotive.configure_for_test(true)
  end
end
