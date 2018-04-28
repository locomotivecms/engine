# encoding: utf-8

FactoryBot.define do

  ## Sections ##
  factory :section, class: Locomotive::Section do
    name 'Header'
    slug 'header'
    template %{<title>{{ section.title }}</title>}
    definition { { name: 'header', settings: [], blocks: [] } }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
  end

end
