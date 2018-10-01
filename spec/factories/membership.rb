# encoding: utf-8

FactoryBot.define do

  ## Memberships ##
  factory :membership, class: Locomotive::Membership do
    role    { 'admin' }
    site    { build(:site) }
    account { Locomotive::Account.where(name: 'Bart Simpson').first || create('admin user') }

    factory :admin do
      role { 'admin' }
      account { create('admin user', locale: 'en') }
    end

    factory :designer do
      role { 'designer' }
      account { create('frenchy user', locale: 'en') }
    end

    factory :author do
      role { 'author' }
      account { create('brazillian user', locale: 'en') }
    end

  end

end
