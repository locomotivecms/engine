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

  s.required_ruby_version = '>= 3.3'

  s.add_dependency 'rails',                           '~> 8.1.3'
  s.add_dependency 'rails-html-sanitizer',            '~> 1.7'

  s.add_dependency 'devise',                          '~> 5.0', '>= 5.0.4'
  s.add_dependency 'devise-encryptable',              '~> 0.3'

  s.add_dependency 'pundit',                          '~> 2.5'

  s.add_dependency 'mongo',                           '~> 2.24'
  s.add_dependency 'mongoid',                         '~> 9.1.0'
  s.add_dependency 'mongoid-tree',                    '~> 2.3'
  s.add_dependency 'origin',                          '~> 2.3.1'

  s.add_dependency 'custom_fields',                   '~> 2.14.0.alpha2'
  s.add_dependency 'locomotivecms_steam',             '~> 2.0.0.alpha1'

  s.add_dependency 'slim',                            '~> 5.2'
  s.add_dependency 'simple_form',                     '~> 5.4'
  s.add_dependency 'kaminari-actionview',             '~> 1.2.2'
  s.add_dependency 'kaminari-mongoid',                '~> 1.0.2'
  s.add_dependency 'bootstrap-kaminari-views',        '~> 0.0.5'
  s.add_dependency 'responders',                      '~> 3.2'
  s.add_dependency 'rails-i18n',                      '~> 8.1.0'
  s.add_dependency 'jbuilder',                        '~> 2.11'

  s.add_dependency 'sprockets-rails',                 '~> 3.5'
  s.add_dependency 'sass-rails',                      '~> 6.0.0'
  s.add_dependency 'coffee-rails',                    '~> 5.0'
  s.add_dependency 'jquery-rails',                    '~> 4.6'
  s.add_dependency 'jquery-ui-rails',                 '>= 8.0', '< 9'

  s.add_dependency 'bootstrap-sass',                  '~> 3.4.1'
  s.add_dependency 'autoprefixer-rails',              '~> 10.4.13'

  s.add_dependency 'font-awesome-sass',               '~> 6.7'

  s.add_dependency 'highline',                        '~> 3.1'
  s.add_dependency 'bazaar',                          '~> 0.0.2'
  s.add_dependency 'json-schema',                     '~> 6.2'

  s.add_dependency 'carrierwave-mongoid',             '>= 1.4', '< 2'
  s.add_dependency 'dragonfly',                       '~> 1.4.0'
  s.add_dependency 'rack-cache',                      '~> 1.17'

  s.add_dependency 'actionmailer-with-request',       '~> 0.5.0'

  s.add_dependency 'grape',                           '~> 3.3'
  s.add_dependency 'grape-entity',                    '~> 1.1'

  s.add_dependency 'carrierwave',                     '>= 2.2.7', '< 3'
end
