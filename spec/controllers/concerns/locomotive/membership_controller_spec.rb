describe Locomotive::Concerns::MembershipController do

   before(:all) do
    class MyController < ActionController::Base
      include Locomotive::Concerns::MembershipController
      include Locomotive::Engine.routes.url_helpers # Required for loading engine routes

      def current_site; end
    end
  end

  after(:all) { Object.send :remove_const, :MyController }

  let(:account)         { build(:account) }
  let(:site)            { build('test site') }
  let(:request)         { ActionDispatch::Request.new({}) }

  let!(:my_controller)  { MyController.new }

  before do
    my_controller.instance_variable_set('@_response', ActionDispatch::Response.new)
    allow(my_controller).to receive(:request).and_return(request)
    allow(my_controller).to receive(:current_locomotive_account).and_return(account)
    allow(my_controller).to receive(:sign_out).with(account)
    allow(my_controller).to receive(:new_locomotive_account_session_url).and_return('/locomotive/session/new')
  end

  context 'when a site is present' do

    before do
      allow(my_controller).to receive(:current_site).and_return(site)
    end

    context 'and the user has a membership' do

      before do
        allow(site).to receive(:membership_for).and_return(site.memberships.first)
      end

      it 'returns true' do
        expect(my_controller.send(:validate_site_membership)).to eq(true)
      end

    end

    context 'and the user does not have a membership' do

      before do
        allow(site).to receive(:membership_for).and_return(nil)
      end

      it 'signs out the user' do
        expect(my_controller).to receive(:sign_out).with(account)
        my_controller.send(:validate_site_membership)
      end

      it 'adds a flash message for no membership' do
        my_controller.send(:validate_site_membership)
        expect(my_controller.flash[:alert]).to be_present
      end

      it 'redirects to the new session url' do
        expect(my_controller).to receive(:redirect_to).with('/locomotive/session/new')
        my_controller.send(:validate_site_membership)
      end

      it 'returns false' do
        expect(my_controller.send(:validate_site_membership)).to eq(false)
      end

    end

  end

  context 'when no site is present' do

    before do
      allow(my_controller).to receive(:current_site).and_return(nil)
    end

    it 'signs out the user' do
      expect(my_controller).to receive(:sign_out).with(account)
      my_controller.send(:validate_site_membership)
    end

    it 'adds a flash message for no membership' do
      my_controller.send(:validate_site_membership)
      expect(my_controller.flash[:alert]).to be_present
    end

    it 'redirects to the new session url' do
      expect(my_controller).to receive(:redirect_to).with('/locomotive/session/new')
      my_controller.send(:validate_site_membership)
    end

    it 'returns false' do
      expect(my_controller.send(:validate_site_membership)).to eq(false)
    end
  end
end
