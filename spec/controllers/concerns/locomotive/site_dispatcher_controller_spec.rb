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

  context 'inheriting from athe site dispatcher' do

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
