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

  s.add_dependency 'rails',                           '>= 5.2.4.2', '< 6.0'
  s.add_dependency 'rails-html-sanitizer',            '~> 1.3.0'

  s.add_dependency 'devise',                          '~> 4.7.1'
  s.add_dependency 'devise-encryptable',              '~> 0.2.0'
  s.add_dependency 'simple_token_authentication',     '~> 1.15.1'

  s.add_dependency 'pundit',                          '~> 1.1.0'

  s.add_dependency 'mongo',                           '2.8.0'
  s.add_dependency 'mongoid',                         '~> 6.4.0'
  s.add_dependency 'mongoid-tree',                    '~> 2.1.0'
  s.add_dependency 'origin',                          '~> 2.3.1'

  s.add_dependency 'custom_fields',                   '~> 2.10.0'
  s.add_dependency 'locomotivecms_steam',             '~> 1.5.3'

  s.add_dependency 'slim',                            '~> 3.0.9'
  s.add_dependency 'simple_form',                     '~> 5.0.0'
  s.add_dependency 'kaminari-actionview',             '~> 1.1.1'
  s.add_dependency 'kaminari-mongoid',                '~> 1.0.1'
  s.add_dependency 'bootstrap-kaminari-views',        '~> 0.0.5'
  s.add_dependency 'responders',                      '~> 2.4.0'
  s.add_dependency 'rails-i18n',                      '~> 5.1.1'
  s.add_dependency 'jbuilder',                        '~> 2.7'

  s.add_dependency 'jquery-rails',                    '~> 4.3.1'
  s.add_dependency 'jquery-ui-rails',                 '~> 6.0.1'
  s.add_dependency 'codemirror-rails',                '~> 5.16.0'
  s.add_dependency 'flash_cookie_session',            '~> 1.1.1'
  s.add_dependency 'bootstrap-sass',                  '~> 3.4.1'
  s.add_dependency 'autoprefixer-rails',              '~> 8.0.0'

  s.add_dependency 'font-awesome-sass',               '~> 5.2.0'

  s.add_dependency 'highline',                        '~> 1.7.10'
  s.add_dependency 'bazaar',                          '~> 0.0.2'
  s.add_dependency 'json-schema',                     '~> 2.8.0'

  s.add_dependency 'carrierwave-mongoid',             '~> 1.1.0'
  s.add_dependency 'dragonfly',                       '~> 1.2.0'
  s.add_dependency 'rack-cache',                      '~> 1.7.1'

  s.add_dependency 'multi_json',                      '~> 1.13.1'
  s.add_dependency 'yajl-ruby',                       '~> 1.3.1'
  s.add_dependency 'actionmailer-with-request',       '~> 0.5.0'
  s.add_dependency 'adomain',                         '~> 0.1.1'

  s.add_dependency 'rack',                            '~> 2.0.8'
  s.add_dependency 'grape',                           '~> 1.1.0'
  s.add_dependency 'grape-entity',                    '0.7.1'

  s.add_dependency 'carrierwave-imageoptim',          '0.1.5'
  s.add_dependency 'image_optim',                     '0.26.3'
  s.add_dependency 'image_optim_pack',                '0.5.1'

end
