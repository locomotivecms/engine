require 'spec_helper'

describe Locomotive::Api::MyAccountController do

  let!(:account) { create(:account) }
  let(:params) do
    {
      "name"                  => "New User",
      "email"                 => "new-user4@a.com",
      "password"              => "asimpleone",
      "password_confirmation" => "asimpleone"
    }
  end

  before do
    Locomotive.config.stubs(:multi_sites?).returns(false)
  end

  context 'logged in' do

    before do
      sign_in account
    end

    describe "#GET show" do
      subject { get :show, locale: :en, format: :json }
      it { is_expected.to be_success }
      specify do
        subject
        expect(assigns(:account)).to eq(account)
      end
    end

    describe "#POST create" do
      subject { post :create, 'account' => params, format: :json }
      it { is_expected.to_not be_success }
    end

    describe 'PUT #update' do
      subject { put :update, "account" => params, format: :json }

      context 'valid params' do
        let(:params) { {'name' => 'new name' } }
        it { is_expected.to be_success }
        it 'updates the account' do
          subject
          account.reload
          expect(account.name).to eq 'new name'
        end
      end

      context 'invalid params' do
        let(:params) { {'name' => '' } }
        it { expect(subject.status).to eq(422) }
      end
    end

  end

  context 'not logged in' do

    before do
      sign_out account
    end

    describe '#GET show' do
      subject { get :show, locale: :en, format: :json }
      it { is_expected.to_not be_success }
    end

    describe "#POST create" do
      subject { post :create, 'account' => params, format: :json }
      it { is_expected.to be_success }
      it 'creates a new account' do
        expect { subject }.to change(Locomotive::Account, :count).by(1)
      end
    end

    describe 'PUT #update' do
      subject { put :update, "account" => params, format: :json }
      it { is_expected.to_not be_success }
    end

  end

end
