require 'spec_helper'

describe Locomotive::API::Middlewares::LoggerMiddleware do

  include Rack::Test::Methods

  describe 'credential redaction in the api.request log line' do

    let(:messages) { [] }

    before do
      allow(Rails.logger).to receive(:info) { |message| messages << message.to_s }

      header 'X-Locomotive-Account-Token', 'header-token-secret'
      post '/locomotive/api/v3/tokens.json',
           email:    'nobody@example.com',
           api_key:  'api-key-secret',
           password: 'password-secret'
    end

    it 'logs one api.request line with the credential fields present but their values filtered' do
      api_lines = messages.select { |m| m.include?('service="api.request"') }
      expect(api_lines.size).to eq 1

      line = api_lines.first

      expect(line).to include('api_key')
      expect(line).to include('password')
      expect(line).to include('HTTP_X_LOCOMOTIVE_ACCOUNT_TOKEN')

      expect(line.scan('[FILTERED]').size).to be >= 3

      expect(line).not_to include('header-token-secret')
      expect(line).not_to include('api-key-secret')
      expect(line).not_to include('password-secret')
    end

  end

  describe 'host-independent filter registration' do

    it 'registers the engine credential keys, not relying on the host app filters' do
      # Rails may replace configured filters with precompiled regular expressions.
      declared = Rails.application.config.filter_parameters
        .map { |f| f.is_a?(Regexp) ? f.source : f.to_s }.join(' ')
      expect(declared).to include('password')
      expect(declared).to include('api_key')
      expect(declared).to include('token')
    end

  end

end
