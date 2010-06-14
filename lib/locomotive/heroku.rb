require 'heroku'

module Locomotive
  module Heroku
    
    extend ActiveSupport::Concern
    
    included do
      class << self
        attr_accessor :heroku_connection
        attr_accessor :heroku_domains
      end
    end
    
    module ClassMethods
      
      def heroku?
        !self.config.heroku.nil? && self.config.heroku.respond_to?(:[])
      end
            
      def enable_heroku
        raise 'Heroku application name is mandatory' if self.config.heroku[:name].blank?
        
        self.open_heroku_connection
        self.enhance_site_model
        
        # "cache" domains for better performance
        self.heroku_domains = self.heroku_connection.list_domains(self.config.heroku[:name]).collect { |h| h[:domain] }
      end
      
      def open_heroku_connection
        login = self.config.heroku[:login] || ENV['HEROKU_LOGIN']
        password = self.config.heroku[:password] || ENV['HEROKU_PASSWORD']
        
        self.heroku_connection = ::Heroku::Client.new(login, password)
      end
      
      def enhance_site_model
        Site.send :include, Locomotive::Heroku::CustomDomain
      end
      
      # manage domains
      
      def add_heroku_domain(name)
        Locomotive.logger "[add heroku domain] #{name}"
        self.heroku_connection.add_domain(self.config.heroku[:name], name)
        self.heroku_domains << name
      end
      
      def remove_heroku_domain(name)
        Locomotive.logger "[remove heroku domain] #{name}"
        self.heroku_connection.remove_domain(self.config.heroku[:name], name)
        self.heroku_domains.delete(name)
      end
      
    end
    
  end
end