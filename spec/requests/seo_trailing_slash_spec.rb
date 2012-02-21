require 'spec_helper'

describe 'Locomotive::Middlewares::SeoTrailingSlash' do

  it 'does not process the "/" url' do
    get '/'
    response.status.should_not be(301)
  end

  it 'does not process the "/locomotive/" url' do
    get '/locomotive/'
    response.status.should_not be(301)
  end

  it 'does not process the "/locomotive/*" urls' do
    get '/locomotive/login'
    response.status.should_not be(301)
  end

  it 'redirects to the url without the trailing slash' do
    get '/hello_world/'
    response.status.should be(301)
  end

end
