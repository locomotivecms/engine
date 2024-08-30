$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:

require 'locomotive/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'locomotivecms'
  s.version     = Locomotive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Didier Lafforgue']
  s.email       = ['didier@nocoffee.fr']
  s.homepage    = 'https://www.locomotivecms.com'
  s.summary     = 'A platform to create, publish and edit sites'
  s.description = 'Locomotive is designed to save your time and help you focus on what matters: front-end technology, standard development process and no learning time for your client.'

  s.files = Dir['{app,config,db,lib,vendor}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.files.reject! { |fn| fn.include?('app/javascript') }

  s.add_dependency 'rails',                           '>= 7.1'
  s.add_dependency 'rails-html-sanitizer',            '~> 1.6.0'

  s.add_dependency 'devise',                          '~> 4.9.3'
  s.add_dependency 'devise-encryptable',              '~> 0.2.0'
  s.add_dependency 'simple_token_authentication',     '~> 1.18.1'

  s.add_dependency 'pundit',                          '~> 2.3.0'

  s.add_dependency 'mongo',                           '~> 2.19.3'
  s.add_dependency 'mongoid',                         '~> 8.0.7'
  s.add_dependency 'mongoid-tree',                    '~> 2.2.0'
  s.add_dependency 'origin',                          '~> 2.3.1'

  s.add_dependency 'custom_fields',                   '~> 2.14.0.alpha1'
  s.add_dependency 'locomotivecms_steam',             '~> 1.8.0.alpha1'

  s.add_dependency 'slim',                            '~> 5.0.0'
  s.add_dependency 'simple_form',                     '~> 5.2.0'
  s.add_dependency 'kaminari-actionview',             '~> 1.2.2'
  s.add_dependency 'kaminari-mongoid',                '~> 1.0.2'
  s.add_dependency 'bootstrap-kaminari-views',        '~> 0.0.5'
  s.add_dependency 'responders',                      '~> 3.1.0'
  s.add_dependency 'rails-i18n',                      '~> 7.0.6'
  s.add_dependency 'jbuilder',                        '~> 2.11'

  s.add_dependency 'sprockets-rails',                 '~> 3.4.2'
  s.add_dependency 'sass-rails',                      '~> 6.0.0'
  s.add_dependency 'coffee-rails',                    '~> 5.0'
  s.add_dependency 'jquery-rails',                    '~> 4.5.1'
  s.add_dependency 'jquery-ui-rails',                 '~> 6.0.1'
  
  s.add_dependency 'flash_cookie_session',            '~> 1.1.6'
  s.add_dependency 'bootstrap-sass',                  '~> 3.4.1'
  s.add_dependency 'autoprefixer-rails',              '~> 10.4.13'

  s.add_dependency 'font-awesome-sass',               '~> 6.3.0'

  s.add_dependency 'highline',                        '~> 2.1.0'
  s.add_dependency 'bazaar',                          '~> 0.0.2'
  s.add_dependency 'json-schema',                     '~> 3.0.0'

  s.add_dependency 'carrierwave-mongoid',             '~> 1.4.0'
  s.add_dependency 'dragonfly',                       '~> 1.4.0'
  s.add_dependency 'rack-cache',                      '~> 1.14.0'

  s.add_dependency 'multi_json',                      '~> 1.15.0'
  s.add_dependency 'yajl-ruby',                       '~> 1.4.3'
  s.add_dependency 'actionmailer-with-request',       '~> 0.5.0'
  s.add_dependency 'adomain',                         '~> 0.2.4'

  s.add_dependency 'grape',                           '~> 2.1.3'
  s.add_dependency 'grape-entity',                    '~> 0.10.0'

  s.add_dependency 'carrierwave',                     '~> 1.3.3'
end
