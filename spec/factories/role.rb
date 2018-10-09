# encoding: utf-8

FactoryBot.define do

  ## Memberships ##
  factory :role, class: Locomotive::Role do
    site    { build(:site) }
  end

end
