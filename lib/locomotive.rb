# require 'locomotive/patches'
require 'locomotive/configuration'
require 'locomotive/liquid'

module Locomotive

  class << self
    attr_accessor :config
    
    def config
      self.config = Configuration.new unless @config
      @config
    end
  end
  
  def self.configure
    self.config ||= Configuration.new
    yield(self.config)
  end
  
end