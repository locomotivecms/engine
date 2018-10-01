# encoding: utf-8

FactoryBot.define do

  ## Snippets ##
  factory :snippet, class: Locomotive::Snippet do
    name { 'My website title' }
    sequence(:slug) { |n| "header#{n*rand(10_000)}" }
    template { %{<title>Acme</title>} }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
  end

end
