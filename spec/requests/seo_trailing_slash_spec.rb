require 'spec_helper'

describe 'Locomotive::Middlewares::SeoTrailingSlash' do

  before(:all) do
    Locomotive::Application.instance.instance_variable_set(:@app, nil) # re-initialize the stack
  end

  it 'does not process the "/" url' do
    get '/'
    response.status.should_not be(301)
  end

  it 'does not process the "/admin/" url' do
    get '/admin/'
    response.status.should_not be(301)
  end

  it 'does not process the "/admin/*" urls' do
    get '/admin/login'
    response.status.should_not be(301)
  end

  it 'redirects to the url without the trailing slash' do
    get '/hello_world/'
    response.status.should be(301)
  end

end