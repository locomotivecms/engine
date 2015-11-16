#!/usr/bin/env gem build
# encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'locomotive/version'

Gem::Specification.new do |s|
  s.name        = 'locomotivecms'
  s.version     = Locomotive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Didier Lafforgue']
  s.email       = ['did@locomotivecms.com']
  s.homepage    = 'http://www.locomotivecms.com'
  s.summary     = 'A platform to create, publish and edit sites'
  s.description = 'Locomotive is designed to save your time and help you focus on what matters: front-end technology, standard development process and no learning time for your client.'

  s.add_dependency 'rake',                            '~> 10.4.2'

  s.add_dependency 'rails',                           '~> 4.2.5'

  # https://github.com/net-ssh/net-ssh/issues/260
  s.add_dependency 'net-ssh',                         '~> 2.10.1.rc1'

  s.add_dependency 'devise',                          '~> 3.5.1'
  s.add_dependency 'devise-encryptable',              '~> 0.2.0'
  s.add_dependency 'simple_token_authentication',     '~> 1.10.0'

  s.add_dependency 'pundit',                          '~> 1.0.0'

  s.add_dependency 'mongoid',                         '~> 4.0.2'
  s.add_dependency 'mongoid-tree',                    '~> 2.0.1'
  s.add_dependency 'mongo_session_store-rails4',      '~> 6.0.0'

  s.add_dependency 'mime-types',                      '~> 2.5'
  s.add_dependency 'custom_fields',                   '~> 2.4.0.rc8'

  s.add_dependency 'locomotivecms_steam',             '~> 1.0.0.rc3'

  s.add_dependency 'slim',                            '~> 3.0.6'
  s.add_dependency 'simple_form',                     '~> 3.2.0'
  s.add_dependency 'kaminari',                        '~> 0.16.3'
  s.add_dependency 'bootstrap-kaminari-views',        '~> 0.0.5'
  s.add_dependency 'responders',                      '~> 2.1.0'
  s.add_dependency 'rails-i18n',                      '~> 4.0.6'

  s.add_dependency 'jquery-rails',                    '~> 4.0.3'
  s.add_dependency 'jquery-ui-rails',                 '~> 5.0.3'
  s.add_dependency 'codemirror-rails',                '~> 5.6'
  s.add_dependency 'flash_cookie_session',            '~> 1.1.1'
  s.add_dependency 'select2-rails',                   '~> 3.5.9'
  s.add_dependency 'compass-rails',                   '2.0.4'
  s.add_dependency 'bootstrap-sass',                  '~> 3.3.5.1'
  s.add_dependency 'autoprefixer-rails',              '~> 6.0.3'

  s.add_dependency 'font-awesome-sass',               '~> 4.4.0'
  s.add_dependency 'nprogress-rails',                 '~> 0.1.6.7'

  s.add_dependency 'highline',                        '~> 1.7.1'
  s.add_dependency 'stringex',                        '~> 2.5.2'
  s.add_dependency 'bazaar',                          '~> 0.0.2'

  s.add_dependency 'carrierwave-mongoid',             '~> 0.7.1'
  s.add_dependency 'carrierwave-aws',                 '~> 1.0.0'
  s.add_dependency 'dragonfly',                       '~> 1.0.7'
  s.add_dependency 'rack-cache',                      '~> 1.1'
  s.add_dependency 'mimetype-fu',                     '~> 0.1.2'

  s.add_dependency 'multi_json',                      '~> 1.11.0'
  s.add_dependency 'actionmailer-with-request',       '~> 0.4.0'

  s.add_dependency 'grape',                           '~> 0.12.0'
  s.add_dependency 'grape-entity',                    '0.4.5'

  s.add_development_dependency "faye-websocket"

  s.files        = Dir[ 'Gemfile',
                        '{app}/**/*',
                        '{config}/**/*',
                        '{lib}/**/*',
                        '{mongodb}/**/*',
                        '{public}/**/*',
                        '{vendor}/**/*']

  s.test_files = Dir[
    'features/**/*',
    'spec/{fixtures,lib,mailers,models,requests,support}/**/*',
    'spec/dummy/Rakefile',
    'spec/dummy/config.ru',
    'spec/dummy/{app,config,lib,script}/**/*',
    'spec/dummy/public/*.html'
  ]

  s.require_path = 'lib'

  s.extra_rdoc_files = [
    'LICENSE',
     'README.md'
  ]

end
