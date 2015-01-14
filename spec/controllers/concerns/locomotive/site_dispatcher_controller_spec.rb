require 'spec_helper'

describe Locomotive::Concerns::SiteDispatcherController do

  before(:all) do
    class MyController < ActionController::Base
      include Locomotive::Concerns::SiteDispatcherController
      include Locomotive::Engine.routes.url_helpers # Required for loading engine routes
    end
  end

  after(:all) { Object.send :remove_const, :MyController }

  let(:my_controller) { MyController.new }

  context 'inheriting the site dispatcher' do

    it 'adds a helper method for current site' do
      expect(my_controller.respond_to?(:current_site, true)).to eq(true)
    end

  end

  describe '#require_site' do

    context 'when there is a current site' do

      before { my_controller.expects(:current_site).returns(true) }

      it 'returns true' do
        expect(my_controller.send(:require_site)).to eq(true)
      end

    end

    context 'when there are no accounts' do

      before do
        Locomotive::Account.expects(:count).returns(0)

        my_controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        my_controller.expects(:current_site).returns(false)
        my_controller.stubs(:installation_url).returns('/locomotive/install/url/')
        my_controller.stubs(:redirect_to).with('/locomotive/install/url/')
      end

      it 'returns false' do
        expect(my_controller.send(:require_site)).to eq(false)
      end

      it 'redirects to the admin installation url' do
        my_controller.expects(:redirect_to).with('/locomotive/install/url/')
        my_controller.send(:require_site)
      end

    end

    context 'when there are no sites' do

      before do
        Locomotive::Account.expects(:count).returns(1)
        Locomotive::Site.expects(:count).returns(0)

        my_controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        my_controller.expects(:current_site).returns(false)
        my_controller.stubs(:installation_url).returns('/locomotive/install/url/')
        my_controller.stubs(:redirect_to).with('/locomotive/install/url/')
      end

      it 'returns false' do
        expect(my_controller.send(:require_site)).to eq(false)
      end

      it 'redirects to the admin installation url' do
        my_controller.expects(:redirect_to).with('/locomotive/install/url/')
        my_controller.send(:require_site)
      end

    end

    context 'when there is no current site' do

      before do
        Locomotive::Account.expects(:count).returns(1)
        Locomotive::Site.expects(:count).returns(1)

        my_controller.instance_variable_set('@_response', ActionDispatch::Response.new)
        my_controller.expects(:current_site).returns(false)
      end

      it 'halts the filter chain' do
        my_controller.stubs(:render_no_site_error)
        expect(my_controller.send(:require_site)).to eq(false)
      end

      it 'renders the no site error' do
        my_controller.expects(:render_no_site_error)
        my_controller.send(:require_site)
      end

    end

  end

  describe '#render_no_site_error' do

    render_views

    controller do
      include Locomotive::Concerns::SiteDispatcherController
      def test_render_no_site
        render_no_site_error
      end
    end

    before do
      @routes.draw { get '/anonymous/test_render_no_site' }
    end

    it 'has a no site error message' do
      get :test_render_no_site
      expect(response.body).to include 'No Site'
    end

    it 'has a 404 not found status' do
      get :test_render_no_site
      expect(response.status).to eq(404)
    end

  end

end
