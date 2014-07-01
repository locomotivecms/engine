require 'spec_helper'

describe Locomotive::Api::AccountsController do

  let(:site)  { create(:site, domains: %w{www.acme.com}) }
  let(:admin) { create(:account) }
  let!(:membership) do
    create(:membership, account: admin, site: site, role: 'admin')
  end
  context 'admin authenticated' do
    before do
      controller.stubs(:current_site).returns(site)
      sign_in admin
    end
    describe 'POST #create' do
      let(:params) {
        {
          "name"                  => "New User",
          "email"                 => "new-user4@a.com",
          "password"              => "asimpleone",
          "password_confirmation" => "asimpleone"
        }
      }

      subject { post :create, "account" => params, format: :json }

      context 'valid input' do
        it { should be_success }
        it 'renders the created user' do
          json_response['email'].should eq 'new-user4@a.com'
          json_response['id'].should_not be_blank
        end
        it 'creates a new user' do
          expect { subject }.to change(Locomotive::Account, :count).by(1)
        end
      end
      context 'invalid input' do
        let(:params) { { invalid: 'input' } }
        its(:status) { should eq 422 }
        it 'does not create a user' do
          expect { subject }.to change(Locomotive::Account, :count).by(0)
        end
      end
    end

    describe 'PUT #update' do
      let(:account) { create(:account) }
      subject { put :update, id: account, "account" => params, format: :json }

      context 'valid params' do
        let(:params) { {'name' => 'new name' } }
        it { should be_success }
        it 'updates the user' do
          subject
          account.reload
          account.name.should eq 'new name'
        end
      end

      context 'invalid params' do
        let(:params) { {'name' => '' } }
        its(:status) { should eq 422 }
      end
    end
  end


  def json_response
    JSON.parse(subject.body)
  end
end
