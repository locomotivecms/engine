require 'spec_helper'

class MyController < ActionController::Base
  include Locomotive::Routing::SiteDispatcher

  include Locomotive::Engine.routes.url_helpers # Required for loading engine routes
end

describe Locomotive::Routing::SiteDispatcher do

  before :each do
    @controller = MyController.new
  end

  context 'inheriting the site dispatcher' do

    before :each do
      @controller = MyController.new
    end

    it 'adds a helper method for current site' do
      @controller.respond_to?(:current_site, true).should be_true
    end

  end

  describe '#fetch_site' do

    before :each do
      @request    = Object.new
      @site       = FactoryGirl.build(:site)

      @controller.stubs(:request).returns(@request)
      @request.stubs(:host).returns('host')
      @request.stubs(:env).returns({})
    end

    it 'returns the current site instance if available' do
      @controller.instance_variable_set(:@current_site, @site)
      @controller.send(:fetch_site).should == @site
    end

    it 'returns the site with matching domain if there is no current site instance' do
      Locomotive::Site.expects(:match_domain).with('host').returns([@site])
      @controller.send(:fetch_site).should == @site
    end

  end

  describe '#current_site' do

    before :each do
      @site = FactoryGirl.build(:site)
    end

    it 'returns the current site instance if available' do
      @controller.instance_variable_set(:@current_site, @site)
      @controller.send(:current_site).should == @site
    end

    it 'runs fetch site if no instance is available' do
      @controller.stubs(:fetch_site).returns(@site)
      @controller.send(:current_site).should == @site
    end

  end

  describe '#require_site' do

    context 'when there is a current site' do

      before :each do
        @controller.expects(:current_site).returns(true)
      end

      it 'returns true' do
        @controller.send(:require_site).should be_true
      end

    end

    context 'when there are no accounts' do

      before :each do
        Locomotive::Account.expects(:count).returns(0)

        @controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        @controller.expects(:current_site).returns(false)
        @controller.stubs(:installation_url).returns('/locomotive/install/url/')
        @controller.stubs(:redirect_to).with('/locomotive/install/url/')
      end

      it 'returns false' do
        @controller.send(:require_site).should be_false
      end

      it 'redirects to the admin installation url' do
        @controller.expects(:redirect_to).with('/locomotive/install/url/')
        @controller.send(:require_site)
      end

    end

    context 'when there are no sites' do

      before :each do
        Locomotive::Account.expects(:count).returns(1)
        Locomotive::Site.expects(:count).returns(0)

        @controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        @controller.expects(:current_site).returns(false)
        @controller.stubs(:installation_url).returns('/locomotive/install/url/')
        @controller.stubs(:redirect_to).with('/locomotive/install/url/')
      end

      it 'returns false' do
        @controller.send(:require_site).should be_false
      end

      it 'redirects to the admin installation url' do
        @controller.expects(:redirect_to).with('/locomotive/install/url/')
        @controller.send(:require_site)
      end

    end

    context 'when there is no current site' do

      before :each do
        Locomotive::Account.expects(:count).returns(1)
        Locomotive::Site.expects(:count).returns(1)

        @controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        @controller.expects(:current_site).returns(false)
      end

      it 'halts the filter chain' do
        @controller.stubs(:render_no_site_error)
        @controller.send(:require_site).should be_false
      end

      it 'renders the no site error' do
        @controller.expects(:render_no_site_error)
        @controller.send(:require_site)
      end

    end

  end

  describe '#render_no_site_error' do

    before :each do
      @request = ActionDispatch::Request.new('rack.input' => 'wtf')

      @controller.instance_variable_set('@_response', ActionDispatch::Response.new)
      @controller.stubs(:request).returns(@request)
      @controller.send(:render_no_site_error)
    end

    it 'should have a no site error message' do
      @controller.response.body.should include 'No Site'
    end

    it 'should have a 404 not found status' do
      @controller.response.should be_not_found
    end

  end

  describe '#validate_site_membership' do

    before :each do
      @account = FactoryGirl.build(:account)
      @site    = FactoryGirl.build(:site)
      @request = ActionDispatch::Request.new({})

      @controller.instance_variable_set('@_response', ActionDispatch::Response.new)
      @controller.stubs(:request).returns(@request)
      @controller.stubs(:current_locomotive_account).returns(@account)
      @controller.stubs(:sign_out).with(@account)
      @controller.stubs(:new_locomotive_account_session_url).returns('/locomotive/session/new')
    end

    context 'when a site is present' do

      before :each do
        @controller.stubs(:current_site).returns(@site)
      end

      context 'and the user has a membership' do

        before :each do
          @site.stubs(:accounts).returns([@account])
        end

        it 'returns true' do
          @controller.send(:validate_site_membership).should be_true
        end

      end

      context 'and the user does not have a membership' do

        before :each do
          @site.stubs(:accounts).returns([])
        end

        it 'signs out the user' do
          @controller.expects(:sign_out).with(@account)
          @controller.send(:validate_site_membership)
        end

        it 'adds a flash message for no membership' do
          @controller.send(:validate_site_membership)
          @controller.flash[:alert].should be_present
        end

        it 'redirects to the new session url' do
          @controller.expects(:redirect_to).with('/locomotive/session/new')
          @controller.send(:validate_site_membership)
        end

        it 'returns false' do
          @controller.send(:validate_site_membership).should be_false
        end

      end

    end

    context 'when no site is present' do

      before :each do
        @controller.stubs(:current_site).returns(nil)
      end

      it 'signs out the user' do
        @controller.expects(:sign_out).with(@account)
        @controller.send(:validate_site_membership)
      end

      it 'adds a flash message for no membership' do
        @controller.send(:validate_site_membership)
        @controller.flash[:alert].should be_present
      end

      it 'redirects to the new session url' do
        @controller.expects(:redirect_to).with('/locomotive/session/new')
        @controller.send(:validate_site_membership)
      end

      it 'returns false' do
        @controller.send(:validate_site_membership).should be_false
      end
    end
  end
end
