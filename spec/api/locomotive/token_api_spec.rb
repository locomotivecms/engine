require 'spec_helper'

describe Locomotive::TokenAPI do
  let(:account) { create :account }

  context 'with email and password' do
    describe 'POST /locomotive/api_test/v2/token' do
      context 'JSON' do
        before do
          post('/locomotive/api_test/v2/token.json', { email: account.email, password: 'easyone' })
        end

        subject { response }

        it { is_expected.to be_success }

        it 'responds with the correct body' do
          expect(parsed_response).to eq({ 'token' => account.reload.authentication_token })
        end

      end
    end

  end

  context 'with email and api_key' do

  end

end
