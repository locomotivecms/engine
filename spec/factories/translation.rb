# encoding: utf-8

FactoryBot.define do

  factory :translation, class: Locomotive::Translation do
    sequence(:key) { |n| "key_#{n*rand(10_000)}" }
    values {{ en: 'foo', fr: 'bar', wk: 'wuuuu' }}
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
  end

end
