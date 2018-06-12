# encoding: utf-8

describe Locomotive::EditorService do

  let(:site) { double(:site) }
  let(:account) { double(:account) }
  let(:page) { double(:page) }
  let(:service) { described_class.new(site, account, page) }
  let(:site_attributes) { {"sections_content": ""} }

  describe '#save' do
    let(:page_attributes) {
      {
        sections_content:
        <<-JSON
            [{
              "id": "10ebe2f8-af88-4d87-9df8-58e3e624d662",
              "name": "Cover 04",
              "type": "cover_04",
              "settings": {},
              "blocks": [
                {
                  "type": "slide",
                  "settings": {
                    "title": "A brand new way to excite <br>your audience",
                    "description": "Who can visualize the sorrow and mineral of a lord if he has the evil sainthood of the seeker.",
                    "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9"
                  },
                  "id": "72a28230-62fb-429c-b7ae-69ae377015b8"
                },
                {
                  "type": "slide",
                  "settings": {
                    "title": "A meaningless form of vision is the uniqueness!",
                    "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9",
                    "description": "Description goes here"
                  },
                  "id": "bc06c67a-d268-44fb-a6de-cff5df845ed7"
                }
              ]
            }]
        JSON
      }
    }

    let(:expected_page_attribute) {
      {
        sections_content:
        <<-JSON
        [{"name": "Cover 04","type": "cover_04","settings": {},"blocks": [{"type": "slide","settings": {"title": "A brand new way to excite <br>your audience","description": "Who can visualize the sorrow and mineral of a lord if he has the evil sainthood of the seeker.","image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9"},},{"type": "slide","settings": {"title": "A meaningless form of vision is the uniqueness!","image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9","description": "Description goes here"},}]}]
        JSON
      }
    }

    subject { service.save(site_attributes, page_attributes) }

    it 'authenticate user'

    it 'save the site static sections'

    it 'save the page section' do
      allow(site).to receive(:update_attributes).with(site_attributes) { true }
      allow(site).to receive(:update_attributes) { true } #TODO check section attributes passed to update
      subject
      expect(page).to eq(nil)
    end
  end

  describe '#remove_ids!' do
    subject { described_class.remove_ids(json) }

    context 'when there is a section id' do
      let(:json) {
        <<-JSON
          [{
            "id": "10ebe2f8-af88-4d87-9df8-58e3e624d662",
            "name": "Cover 04",
            "type": "cover_04",
            "settings": {},
            "blocks": [
              {
                "type": "slide",
                "settings": {
                  "title": "A brand new way to excite <br>your audience",
                  "description": "Who can visualize the sorrow and mineral of a lord if he has the evil sainthood of the seeker.",
                  "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9"
                },
                "id": "72a28230-62fb-429c-b7ae-69ae377015b8"
              },
              {
                "type": "slide",
                "settings": {
                  "title": "A meaningless form of vision is the uniqueness!",
                  "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9",
                  "description": "Description goes here"
                },
                "id": "bc06c67a-d268-44fb-a6de-cff5df845ed7"
              }
            ]
          }]
        JSON
      }

      let(:expected) {
        <<-JSON
          [{
            "name": "Cover 04",
            "type": "cover_04",
            "settings": {},
            "blocks": [
              {
                "type": "slide",
                "settings": {
                  "title": "A brand new way to excite <br>your audience",
                  "description": "Who can visualize the sorrow and mineral of a lord if he has the evil sainthood of the seeker.",
                  "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9"
                }
              },
              {
                "type": "slide",
                "settings": {
                  "title": "A meaningless form of vision is the uniqueness!",
                  "image": "https://images.unsplash.com/photo-1437532437759-a0ce0535dfed?ixlib=rb-0.3.5&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;s=2c277dc10ba53e29a62d09c13cdf01b9",
                  "description": "Description goes here"
                }
              }
            ]
          }]
        JSON
      }

      it "remove the ids" do
        is_expected.to eq(JSON.parse(expected).to_json)
      end
    end

  end
end
