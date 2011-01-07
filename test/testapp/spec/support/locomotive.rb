Locomotive.configure do |config|
  config.default_domain = 'example.com'
  config.enable_logs = true
end

module Locomotive
  class TestController < ApplicationController

    include Locomotive::Render

    attr_accessor :output, :current_site, :current_admin

    def render(options = {})
      self.output = options[:text]
    end

    def response
      @_response ||= TestResponse.new
    end

    def request
      @_request ||= TestRequest.new
    end

  end

  class TestResponse < ActionDispatch::TestResponse

  end

  class TestRequest < ActionDispatch::TestRequest

    attr_accessor :fullpath

  end
end
