require 'spec_helper'

describe Locomotive::Liquid::Drops::CurrentUser do

  before(:each) do
    @page = FactoryGirl.build(:sub_page)

    @site = @page.site
    @site.pages.expects(:any_in).returns([@page])

    @controller = Locomotive::TestController.new
    @controller.stubs(:flash).returns(ActionDispatch::Flash::FlashHash.new())
    @controller.stubs(:params).returns(url: '/subpage')
    @controller.stubs(:request).returns(OpenStruct.new(url: '/subpage', fullpath: '/subpage'))
    @controller.current_site = @site

    @admin = FactoryGirl.build(:admin).account
  end

  def expect_render(template, text)
    @page.raw_template = template
    @page.send(:serialize_template)
    @controller.expects(:render).with(text: text, layout: false, status: :ok).returns(true)
    @controller.send(:render_locomotive_page)
  end

  context '#logged_in?' do
    it 'returns false when no user is logged in' do
      expect_render('{{ current_user.logged_in? }}', 'false')
    end
    it 'returns true when there is a user logged in' do
      @controller.expects(:current_admin).twice.returns(true)
      expect_render('{{ current_user.logged_in? }}', 'true')
    end
  end

  context '#name' do
    it 'returns nothing when no user is logged in' do
      expect_render('{{ current_user.name }}', '')
    end
    it 'returns the username when the user is logged in' do
      @controller.expects(:current_admin).twice.returns(@admin)
      expect_render('{{ current_user.name }}', 'Admin')
    end
  end

  context '#email' do
    it 'returns nothing when no user is logged in' do
      expect_render('{{ current_user.email }}', '')
    end
    it 'returns the username when the user is logged in' do
      @controller.expects(:current_admin).twice.returns(@admin)
      expect_render('{{ current_user.email }}', 'admin@locomotiveapp.org')
    end
  end

  context '#logout_path' do
    it 'returns the logout url' do
      expect_render('{{ current_user.logout_path }}', '/admin/sign_out')
    end
  end

end
