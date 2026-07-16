require 'rails_helper'

# Contract: `criteria.first!` returns the document, or raises
# Mongoid::Errors::DocumentNotFound when the criteria matches nothing (the admin
# controllers rely on this for a 404 on `where(slug: ...).first!`).
describe 'Mongoid::Criteria#first!' do

  let(:site) { create(:site) }

  def create_content_type(slug)
    site.content_types.create!(name: slug.capitalize, slug: slug, label_field_name: 'title') do |ct|
      ct.entries_custom_fields.build(label: 'Title', type: 'string')
    end
  end

  it 'returns the matching document' do
    content_type = create_content_type('articles')

    expect(site.content_types.where(slug: 'articles').first!).to eq(content_type)
  end

  it 'raises DocumentNotFound when nothing matches' do
    expect {
      site.content_types.where(slug: 'does-not-exist').first!
    }.to raise_error(Mongoid::Errors::DocumentNotFound)
  end

end
