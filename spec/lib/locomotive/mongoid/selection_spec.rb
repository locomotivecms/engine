require 'rails_helper'

describe 'Locomotive Mongoid symbol-operator selection' do

  let(:site)         { create(:site) }
  let(:content_type) { create(:content_type, :article, site: site) }

  def create_entry(attributes = {})
    content_type.entries.build({ title: 'Entry', _label_field_name: 'title' }.merge(attributes)).tap do |entry|
      entry.send(:set_site)
      entry.save!
    end
  end

  it 'filters with a greater-than-or-equal symbol operator' do
    3.times { create_entry }

    expect(content_type.entries.where(:_position.gte => 1).pluck(:_position).sort).to eq([1, 2])
  end

  it 'filters with an in symbol operator' do
    3.times { create_entry }

    expect(content_type.entries.where(:_position.in => [0, 2]).pluck(:_position).sort).to eq([0, 2])
  end

  it 'filters with a not-equal symbol operator' do
    3.times { create_entry }

    expect(content_type.entries.where(:_position.ne => 1).pluck(:_position).sort).to eq([0, 2])
  end

  it 'combines a symbol operator with a plain equality clause on another field' do
    create_entry(title: 'Match')
    create_entry(title: 'Other')
    create_entry(title: 'Match')

    result = content_type.entries.where(:_position.gte => 1).where(title: 'Match')

    expect(result.pluck(:_position).sort).to eq([2])
  end

end
