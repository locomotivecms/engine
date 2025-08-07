require 'rails_helper'

RSpec.describe 'Locomotive JSON page', type: :request do

  let(:site) { create('existing site', domains: ['www.example.com']) }

  before do 
    page = site.pages.create(
      parent: site.pages.home.first, 
      title: 'Post form', 
      slug: 'post-form', 
      response_type: 'application/json', 
      published: true,
      raw_template: %({ "email":"{{ params.email }}" })
    )
  end

  it 'returns a response' do
    headers = { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' }
    post "/post-form.json", params: { email: 'john@doe.net' }, headers: headers, as: :json
    expect(response).to have_http_status(200)
    expect(response.body).to eq(%({ "email":"john@doe.net" }))
  end

end