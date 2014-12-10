require 'spec_helper'

class MyController < ActionController::Base
  include Locomotive::Concerns::MembershipController

  include Locomotive::Engine.routes.url_helpers # Required for loading engine routes
end

describe Locomotive::Concerns::MembershipController do

  let(:account)     { FactoryGirl.build(:account) }
  let(:site)        { FactoryGirl.build(:site) }
  let(:request)     { ActionDispatch::Request.new({}) }
  let!(:controller) { MyController.new }

  before do
    controller.instance_variable_set('@_response', ActionDispatch::Response.new)
    controller.stubs(:request).returns(request)
    controller.stubs(:current_locomotive_account).returns(account)
    controller.stubs(:sign_out).with(account)
    controller.stubs(:new_locomotive_account_session_url).returns('/locomotive/session/new')
  end

  context 'when a site is present' do

    before do
      controller.stubs(:current_site).returns(site)
    end

    context 'and the user has a membership' do

      before do
        site.stubs(:membership_for).returns(account)
      end

      it 'returns true' do
        controller.send(:validate_site_membership).should be_true
      end

    end

    context 'and the user does not have a membership' do

      before do
        site.stubs(:membership_for).returns(nil)
      end

      it 'signs out the user' do
        controller.expects(:sign_out).with(account)
        controller.send(:validate_site_membership)
      end

      it 'adds a flash message for no membership' do
        controller.send(:validate_site_membership)
        controller.flash[:alert].should be_present
      end

      it 'redirects to the new session url' do
        controller.expects(:redirect_to).with('/locomotive/session/new')
        controller.send(:validate_site_membership)
      end

      it 'returns false' do
        controller.send(:validate_site_membership).should be_false
      end

    end

  end

  context 'when no site is present' do

    before do
      controller.stubs(:current_site).returns(nil)
    end

    it 'signs out the user' do
      controller.expects(:sign_out).with(account)
      controller.send(:validate_site_membership)
    end

    it 'adds a flash message for no membership' do
      controller.send(:validate_site_membership)
      controller.flash[:alert].should be_present
    end

    it 'redirects to the new session url' do
      controller.expects(:redirect_to).with('/locomotive/session/new')
      controller.send(:validate_site_membership)
    end

    it 'returns false' do
      controller.send(:validate_site_membership).should be_false
    end
  end
end
