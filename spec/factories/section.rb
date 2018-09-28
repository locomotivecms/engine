# encoding: utf-8

FactoryBot.define do

  ## Sections ##
  factory :section, class: Locomotive::Section do
    name 'Header'
    slug 'header'
    template %{<title>{{ section.settings.title }}</title>}
    definition { {
      name:     'header',
      settings: [
        { id: 'title', type: 'text'}
      ],
      blocks: [
        { type: 'slide', name: 'Slide', settings: [
          { id: 'picture', type: 'image_picker' }
        ] }
      ]
    } }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
  end

end
