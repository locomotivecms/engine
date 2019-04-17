# encoding: utf-8

FactoryBot.define do

  ## Sections ##
  factory :section, class: Locomotive::Section do
    name { 'Header' }
    slug { 'header' }
    template { %{<title>{{ section.settings.title }}</title>} }
    definition { {
      name:     'header',
      settings: [
        { label: 'Title', id: 'title', type: 'text' }
      ],
      blocks: [
        { type: 'slide', name: 'Slide', settings: [
          { id: 'picture', type: 'image_picker' }
        ] }
      ]
    } }
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }

    trait :gallery do
      name { 'Gallery' }
      slug { 'gallery' }
      template { %({% for block in section.blocks %}<img src="{{ block.settings.image }}"/>{% endfor %}) }
      definition { {
        name:     'gallery',
        settings: [],
        blocks: [
          {
            type: 'image',
            name: 'Image',
            settings: [
              { id: 'picture', label: 'Picture', type: 'image_picker', compress: { max_width: 1920, quality: 0.7 } }
            ]
          }
        ]
      } }
    end
  end

end
