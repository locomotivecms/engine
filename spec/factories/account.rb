# encoding: utf-8

FactoryBot.define do

  # Accounts ##
  factory :account, class: Locomotive::Account do
    name { 'Bart Simpson' }
    email { generate(:email) }
    password { 'easyone' }
    password_confirmation { 'easyone' }
    locale { 'en' }

    factory 'admin user' do
      name { 'Admin' }
      email { 'admin@locomotiveapp.org' }
    end

    factory 'frenchy user' do
      name { 'Jean Claude' }
      email { 'jean@frenchy.fr' }
      locale { 'fr' }
    end

    factory 'portuguese user' do
      name { 'Tiago Fernandes' }
      email { 'tjg.fernandes@gmail.com' }
      locale { 'pt' }
    end

    factory 'brazillian user' do
      name { 'Jose Carlos' }
      email { 'jose@carlos.com.br' }
      locale { 'pt-BR' }
    end

    factory 'italian user' do
      name { 'Paolo Rossi' }
      email { 'paolo@paolo-rossi.it' }
      locale { 'it' }
    end

    factory 'polish user' do
      name { 'Paweł Wilk' }
      email { 'pawel@randomseed.pl' }
      locale { 'pl' }
    end

    factory 'japanese user' do
      name { 'OSA Shunsuke' }
      email { 'xxxcaqui@gmail.com' }
      locale { 'ja' }
    end

    factory 'bulgarian user' do
      name { 'Lyuben Petrov' }
      email { 'lyuben.y.petrov@gmail.com' }
      locale { 'bg' }
    end
  end

end
