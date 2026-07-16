require 'rails_helper'

describe 'Locomotive Mongoid Document#as_json' do

  let(:site) { create(:site) }

  it 'mirrors _id into an id key' do
    json = site.as_json

    expect(json['id']).to eq(json['_id'])
    expect(json['id']).to eq(site._id.to_s)
  end

end
