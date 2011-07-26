require 'heroku'
require 'heroku/client'
require 'locomotive/hosting/heroku/custom_domain'
require 'locomotive/hosting/heroku/first_installation'

module Locomotive
  module Hosting
    module Heroku
      module Enabler

        extend ActiveSupport::Concern

        included do
          class << self
            attr_accessor :heroku_connection
            attr_accessor :heroku_domains
          end
        end

        module ClassMethods

          def enable_heroku!
            self.config.domain = 'heroku.com' unless self.config.multi_sites?

            self.config.heroku ||= {}
            self.config.heroku[:name] = ENV['APP_NAME']

            raise 'Heroku application name is mandatory' if self.config.heroku[:name].blank?

            self.open_heroku_connection

            self.enhance_site_model

            self.apply_patches

            # "cache" domains for better performance
            self.heroku_domains = self.heroku_connection.list_domains(self.config.heroku[:name]).collect { |h| h[:domain] }
          end

          def open_heroku_connection
            login = ENV['HEROKU_LOGIN'] || self.config.heroku[:login]
            password = ENV['HEROKU_PASSWORD'] || self.config.heroku[:password]

            self.heroku_connection = ::Heroku::Client.new(login, password)
          end

          def enhance_site_model
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
            Locomotive.log "[add heroku domain] #{name}"
            self.heroku_connection.add_domain(self.config.heroku[:name], name)
            self.heroku_domains << name
          end

          def remove_heroku_domain(name)
            Locomotive.log "[remove heroku domain] #{name}"
            self.heroku_connection.remove_domain(self.config.heroku[:name], name)
            self.heroku_domains.delete(name)
          end

          # rack_cache: disabled because of Varnish
          def rack_cache?
            false
          end

        end

      end
    end
  end
end