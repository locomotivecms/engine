require 'spec_helper'

describe Locomotive::Concerns::MembershipController do

   before(:all) do
    class MyController < ActionController::Base
      include Locomotive::Concerns::MembershipController
      include Locomotive::Engine.routes.url_helpers # Required for loading engine routes
    end
  end

  after(:all) { Object.send :remove_const, :MyController }

  let(:account)         { FactoryGirl.build(:account) }
  let(:site)            { FactoryGirl.build(:site) }
  let(:request)         { ActionDispatch::Request.new({}) }

  let!(:my_controller)  { MyController.new }

  before do
    my_controller.instance_variable_set('@_response', ActionDispatch::Response.new)
    my_controller.stubs(:request).returns(request)
    my_controller.stubs(:current_locomotive_account).returns(account)
    my_controller.stubs(:sign_out).with(account)
    my_controller.stubs(:new_locomotive_account_session_url).returns('/locomotive/session/new')
  end

  context 'when a site is present' do

    before do
      my_controller.stubs(:current_site).returns(site)
    end

    context 'and the user has a membership' do

      before do
        site.stubs(:membership_for).returns(account)
      end

      it 'returns true' do
        expect(my_controller.send(:validate_site_membership)).to eq(true)
      end

    end

    context 'and the user does not have a membership' do

      before do
        site.stubs(:membership_for).returns(nil)
      end

      it 'signs out the user' do
        my_controller.expects(:sign_out).with(account)
        my_controller.send(:validate_site_membership)
      end

      it 'adds a flash message for no membership' do
        my_controller.send(:validate_site_membership)
        expect(my_controller.flash[:alert]).to be_present
      end

      it 'redirects to the new session url' do
        my_controller.expects(:redirect_to).with('/locomotive/session/new')
        my_controller.send(:validate_site_membership)
      end

      it 'returns false' do
        expect(my_controller.send(:validate_site_membership)).to eq(false)
      end

    end

  end

  context 'when no site is present' do

    before do
      my_controller.stubs(:current_site).returns(nil)
    end

    it 'signs out the user' do
      my_controller.expects(:sign_out).with(account)
      my_controller.send(:validate_site_membership)
    end

    it 'adds a flash message for no membership' do
      my_controller.send(:validate_site_membership)
      expect(my_controller.flash[:alert]).to be_present
    end

    it 'redirects to the new session url' do
      my_controller.expects(:redirect_to).with('/locomotive/session/new')
      my_controller.send(:validate_site_membership)
    end

    it 'returns false' do
      expect(my_controller.send(:validate_site_membership)).to eq(false)
    end
  end
end
