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
  s.email       = ['did@locomotivecms.com']
  s.homepage    = 'http://www.locomotivecms.com'
  s.summary     = 'A Next Generation Sexy CMS for Rails 3'
  s.description = 'LocomotiveCMS is a next generation CMS system with sexy admin tools, liquid templating, and inline editing powered by mongodb and rails 3.2'

  s.add_dependency 'rake',                            '~> 10.0.0'

  s.add_dependency 'rails',                           '~> 3.2.15'

  s.add_dependency 'devise',                          '2.2.7'
  s.add_dependency 'devise-encryptable',              '~> 0.1.1'
  s.add_dependency 'cancan',                          '1.6.7'

  s.add_dependency 'mongoid',                         '~> 3.1.5'
  s.add_dependency 'mongoid-tree',                    '~> 1.0.3'
  s.add_dependency 'mongoid_migration',               '~> 0.0.8'
  s.add_dependency 'mongo_session_store-rails3',      '~> 4.1.1'

  s.add_dependency 'custom_fields',                   '~> 2.3.1'

  s.add_dependency 'kaminari',                        '~> 0.14.1'

  s.add_dependency 'haml',                            '~> 4.0.2'
  s.add_dependency 'jquery-rails',                    '~> 2.1.4'
  s.add_dependency 'rails-backbone',                  '~> 0.7.2'
  s.add_dependency 'codemirror-rails',                '~> 3.13'
  s.add_dependency 'locomotive-tinymce-rails',        '~> 3.5.8.2'
  s.add_dependency 'locomotive-aloha-rails',          '~> 0.23.2.2'
  s.add_dependency 'flash_cookie_session',            '~> 1.1.1'

  s.add_dependency 'locomotivecms_solid',             '~> 0.2.2'
  s.add_dependency 'formtastic',                      '~> 2.2.1'
  s.add_dependency 'responders',                      '~> 0.9.2'
  s.add_dependency 'cells',                           '~> 3.8.0'
  s.add_dependency 'RedCloth',                        '~> 4.2.8'
  s.add_dependency 'redcarpet',                       '~> 3.0.0'
  s.add_dependency 'sanitize',                        '2.0.3'
  s.add_dependency 'highline',                        '~> 1.6.2'
  s.add_dependency 'stringex',                        '~> 2.0.3'

  s.add_dependency 'carrierwave-mongoid',             '~> 0.6.2'
  s.add_dependency 'fog',                             '~> 1.12.1'
  s.add_dependency 'dragonfly',                       '~> 0.9.15'
  s.add_dependency 'rack-cache',                      '~> 1.1'
  s.add_dependency 'mimetype-fu',                     '~> 0.1.2'

  s.add_dependency 'multi_json',                      '~> 1.7.3'
  s.add_dependency 'httparty',                        '~> 0.11.0'
  s.add_dependency 'actionmailer-with-request',       '~> 0.4.0'

  s.add_dependency 'SystemTimer' if RUBY_VERSION =~ /1.8/

  s.add_development_dependency "faye-websocket", '~> 0.4.7' # with 0.5, cucumber features are broken.

  s.files        = Dir[ 'Gemfile',
                        '{app}/**/*',
                        '{config}/**/*',
                        '{lib}/**/*',
                        '{mongodb}/**/*',
                        '{public}/**/*',
                        '{vendor}/**/*']

  s.test_files = Dir[
    'features/**/*',
    'spec/{cells,fixtures,lib,mailers,models,requests,support}/**/*',
    'spec/dummy/Rakefile',
    'spec/dummy/config.ru',
    'spec/dummy/{app,config,lib,script}/**/*',
    'spec/dummy/public/*.html'
  ]

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    'LICENSE',
     'README.textile'
  ]

end
