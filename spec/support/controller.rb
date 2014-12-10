module Locomotive
  class TestController < ApplicationController

    include Locomotive::Render

    attr_accessor :output, :status, :current_site, :current_locomotive_account

    def render(options = {})
      self.output = options[:text]
      self.status = options[:status]
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
