require 'heroku'
require 'heroku/client'
require 'locomotive/hosting/heroku/custom_domain'
require 'locomotive/hosting/heroku/first_installation'

module Locomotive
  module Hosting
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
          self.config.hosting == :heroku ||
          (self.config.hosting == :auto && ENV['HEROKU_SLUG'].present?)
        end

        def enable_heroku
          self.config.domain = 'heroku.com' unless self.config.multi_sites?

          self.config.heroku ||= {}
          self.config.heroku[:name] = ENV['APP_NAME']

          raise 'Heroku application name is mandatory' if self.config.heroku[:name].blank?

          self.open_heroku_connection

          self.enhance_site_model_with_heroku

          self.apply_patches

          # "cache" domains for better performance
          self.heroku_domains = self.heroku_connection.list_domains(self.config.heroku[:name]).collect { |h| h[:domain] }
        end

        def open_heroku_connection
          login = self.config.heroku[:login] || ENV['HEROKU_LOGIN']
          password = self.config.heroku[:password] || ENV['HEROKU_PASSWORD']

          self.heroku_connection = ::Heroku::Client.new(login, password)
        end

        def enhance_site_model_with_heroku
          Site.send :include, Locomotive::Hosting::Heroku::CustomDomain
          Site.send :include, Locomotive::Hosting::Heroku::FirstInstallation
        end

        def apply_patches
          # for various reasons, Heroku can modify the behaviour of an application by changing the gem versions (json/pure for instance)
          # so the purpose of this method is to correct those potential differences.

          # http://blog.ethanvizitei.com/2010/11/json-pure-ruins-my-morning.html
          Fixnum.class_eval { def to_json(options = nil); to_s; end }
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
end