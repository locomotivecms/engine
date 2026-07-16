require 'spec_helper'

describe Locomotive::API::Resources::TokenResource do

  include Rack::Test::Methods

  let(:account) { create(:account) }
  let(:url)     { '/locomotive/api/v3/tokens.json' }

  describe 'password flow' do
    it 'issues 201 and the persisted account token for valid credentials' do
      post(url, email: account.email, password: 'easyone')
      expect(last_response.status).to eq 201
      expect(account.reload.authentication_token).to be_present
      expect(parsed_response).to eq('token' => account.authentication_token)
    end

    it 'is case-insensitive on the email' do
      post(url, email: account.email.upcase, password: 'easyone')
      expect(last_response.status).to eq 201
      expect(parsed_response['token']).to be_present
      expect(parsed_response).to eq('token' => account.reload.authentication_token)
    end

    it 'rejects a wrong password with 401 and no token' do
      post(url, email: account.email, password: 'wrong')
      expect(last_response.status).to eq 401
      expect(parsed_response).not_to have_key('token')
    end

    it 'rejects an unknown email with 401 and no token' do
      post(url, email: 'nobody@example.com', password: 'easyone')
      expect(last_response.status).to eq 401
      expect(parsed_response).not_to have_key('token')
    end
  end

  describe 'credential error responses' do
    it 'answers every invalid credential combination identically' do
      responses = [
        { email: account.email,        password: 'wrong'   },
        { email: 'nobody@example.com', password: 'easyone' },
        { email: account.email,        api_key:  'bad-key' },
        { email: account.email }
      ].map do |request_params|
        post(url, request_params)
        [last_response.status, last_response.body, last_response.headers['X-Error-Detail']]
      end

      expect(responses.uniq.size).to eq 1
    end
  end

  describe 'missing email' do
    it 'is rejected with 422 because email is a required parameter' do
      post(url, password: 'easyone')
      expect(last_response.status).to eq 422
    end
  end

  describe 'account API key flow' do
    it 'issues 201 and that account token for a valid api_key' do
      post(url, email: account.email, api_key: account.api_key)
      expect(last_response.status).to eq 201
      expect(account.reload.authentication_token).to be_present
      expect(parsed_response).to eq('token' => account.authentication_token)
    end

    it 'gives the api_key priority over a foreign email and a wrong password' do
      other = create(:account)
      post(url, email: other.email, password: 'wrong', api_key: account.api_key)
      expect(last_response.status).to eq 201
      expect(account.reload.authentication_token).to be_present
      expect(parsed_response).to eq('token' => account.authentication_token)
    end

    it 'does not fall back to the password when the api_key is invalid' do
      post(url, email: account.email, password: 'easyone', api_key: 'wrong-key')
      expect(last_response.status).to eq 401
      expect(parsed_response).not_to have_key('token')
    end

    it 'still requires the email parameter even with an api_key (422)' do
      post(url, api_key: account.api_key)
      expect(last_response.status).to eq 422
    end
  end

  describe 'token stability' do
    it 'returns the same persisted token on repeated issuance' do
      post(url, email: account.email, password: 'easyone')
      first_token = parsed_response['token']

      post(url, email: account.email, password: 'easyone')
      expect(parsed_response['token']).to be_present
      expect(parsed_response['token']).to eq first_token
      expect(parsed_response['token']).to eq account.reload.authentication_token
    end
  end

  describe 'error boundary' do
    it 'returns a generic 500 for an unexpected error' do
      allow(Locomotive::Account).to receive(:create_api_token).and_raise(StandardError, 'boom')

      post(url, email: account.email, password: 'easyone')

      expect(last_response.status).to eq 500
      expect(parsed_response).to eq('error' => 'Internal server error')
    end

    it 'answers a failed credential with a uniform 401 and no internal detail' do
      post(url, email: account.email, password: 'wrong')
      expect(last_response.status).to eq 401
      expect(parsed_response).to eq('error' => 'Invalid credentials')
      expect(last_response.headers).not_to have_key('X-Error-Detail')
    end
  end

end
