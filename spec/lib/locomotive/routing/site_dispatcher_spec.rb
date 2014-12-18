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
      expect(@controller.respond_to?(:current_site, true)).to eq(true)
    end

  end

  describe '#require_site' do

    context 'when there is a current site' do

      before :each do
        @controller.expects(:current_site).returns(true)
      end

      it 'returns true' do
        expect(@controller.send(:require_site)).to eq(true)
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
        expect(@controller.send(:require_site)).to eq(false)
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
        expect(@controller.send(:require_site)).to eq(false)
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
        expect(@controller.send(:require_site)).to eq(false)
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

    it 'has a no site error message' do
      expect(@controller.response.body).to include 'No Site'
    end

    it 'has a 404 not found status' do
      expect(@controller.response.status).to eq(404)
    end

  end

end
