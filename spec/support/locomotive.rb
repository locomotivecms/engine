Locomotive.configure do |config|
  config.default_domain = 'example.com'
  config.enable_logs = true
end

module Locomotive
  class TestController
   
    include Locomotive::Render
   
    attr_accessor :output, :current_site, :current_admin
   
    def render(options = {})
      self.output = options[:text]
    end
    
    def response
      @response ||= TestResponse.new
    end
    
    def request
      @request ||= TestRequest.new
    end

  end
  
  class TestResponse
    
    attr_accessor :headers
    
    def initialize
      self.headers = {}
    end
    
  end
  
  class TestRequest
    
    attr_accessor :fullpath
    
  end
end