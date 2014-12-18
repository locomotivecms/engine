require 'spec_helper'

describe 'Locomotive::Middlewares::SeoTrailingSlash' do

  it 'does not process the "/" url' do
    get '/'
    expect(response.status).to_not eq(301)
  end

  it 'does not process the "/locomotive/" url' do
    get '/locomotive/'
    expect(response.status).to_not eq(301)
  end

  it 'does not process the "/locomotive/*" urls' do
    get '/locomotive/login'
    expect(response.status).to_not eq(301)
  end

  it 'redirects to the url without the trailing slash' do
    get '/hello_world/'
    expect(response.status).to eq(301)
  end

  it 'removes the trailing slash but preserves the query' do
    get '/hello_world/?test=name'
    expect(response.status).to eq(301)
    expect(response.location).to eq('http://www.example.com/hello_world?test=name')
  end

end
