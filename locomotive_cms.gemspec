#!/usr/bin/env gem build
# encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'locomotive/version'

Gem::Specification.new do |s|
  s.name        = 'locomotive_cms'
  s.version     = Locomotive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Didier Lafforgue']
  s.email       = ['didier@nocoffee.fr']
  s.homepage    = 'http://locomotivecms.com'
  s.summary     = 'A next generation sexy CMS for Rails 3'
  s.description = 'Locomotive is a next generation CMS with sexy admin tools, liquid templating, and inline editing powered by MongoDB and Rails 3.'

  s.required_rubygems_version = '>= 1.3.6'
  
  s.add_dependency 'rake',                            '~> 0.9.2'

  s.add_dependency 'rails',                           '~> 3.1.3'

  s.add_dependency 'devise',                          '~> 1.5.3'
  s.add_dependency 'cancan',                          '~> 1.6.7'

  s.add_dependency 'mongo',                           '~> 1.5.2'
  s.add_dependency 'bson_ext',                        '~> 1.5.2'
  s.add_dependency 'mongoid',                         '~> 2.4.2'
  s.add_dependency 'locomotive_mongoid_acts_as_tree', '~> 0.1.5.8'

  s.add_dependency 'custom_fields',                   '~> 2.0.0.rc2'

  s.add_dependency 'kaminari',                        '~> 0.13.0'

  s.add_dependency 'haml',                            '~> 3.1.3'
  s.add_dependency 'sass-rails',                      '~> 3.1.5'
  s.add_dependency 'coffee-script',                   '~> 2.2.0'
  s.add_dependency 'uglifier',                        '~> 1.2.2'
  s.add_dependency 'compass',                         '~> 0.12.alpha.4'
  s.add_dependency 'jquery-rails',                    '~> 1.0.16'
  s.add_dependency 'rails-backbone',                  '~> 0.5.4'
  s.add_dependency 'codemirror-rails',                '~> 2.21'
  s.add_dependency 'locomotive-tinymce-rails',        '~> 3.4.7'
  s.add_dependency 'locomotive-aloha-rails',          '~> 0.20.1'
  s.add_dependency 'flash_cookie_session',            '~> 1.1.1'

  s.add_dependency 'locomotive_liquid',               '2.2.2'
  s.add_dependency 'formtastic',                      '~> 2.0.2'
  s.add_dependency 'responders',                      '~> 0.6.4'
  s.add_dependency 'cells',                           '~> 3.8.0'
  s.add_dependency 'RedCloth',                        '~> 4.2.8'
  s.add_dependency 'sanitize',                        '~> 2.0.3'
  s.add_dependency 'highline',                        '~> 1.6.2'

  s.add_dependency 'rmagick',                         '~> 2.12.2'
  s.add_dependency 'carrierwave-mongoid',             '~> 0.1.3'
  s.add_dependency 'fog',                             '~> 1.0.0'
  s.add_dependency 'dragonfly',                       '~> 0.9.8'
  s.add_dependency 'rack-cache',                      '~> 1.1'
  s.add_dependency 'mimetype-fu',                     '~> 0.1.2'

  s.add_dependency 'httparty',                        '~> 0.8.1'
  s.add_dependency 'actionmailer-with-request',       '~> 0.3.0'
  
  # s.add_dependency 'delayed_job_mongoid',             '~> 1.0.8'

  s.add_dependency 'SystemTimer' if RUBY_VERSION =~ /1.8/

  # Development dependencies
  # ------------------------
  
  s.add_development_dependency 'rspec-rails', '~> 2.6.1'
  s.add_development_dependency 'rspec-cells', '~> 0.1.2'

  s.add_development_dependency 'unicorn',     '~> 4.2.0'

  s.files = Dir[
    'Gemfile',
    '{app}/**/*',
    '{config}/**/*',
    '{lib}/**/*',
    '{public}/**/*',
    '{vendor}/**/*'
  ]

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    'LICENSE',
     'README.textile'
  ]

end