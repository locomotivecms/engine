require 'spec_helper'

describe Locomotive::Httparty::Webservice do

  context '#consuming' do

    before(:each) do
      @response = mock('response', code: 200, parsed_response: OpenStruct.new)
    end

    it 'sets the base uri from a simple url' do
      Locomotive::Httparty::Webservice.expects(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org' }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org')
    end

    it 'sets the base uri from a much more complex url' do
      Locomotive::Httparty::Webservice.expects(:get).with('/feed/weather.ashx?key=secretapikey&format=json', { base_uri: 'http://free.worldweatheronline.com' }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://free.worldweatheronline.com/feed/weather.ashx?key=secretapikey&format=json')
    end

    it 'sets both the base uri and the path from an url with parameters' do
      Locomotive::Httparty::Webservice.expects(:get).with('/api/read/json?num=3', { base_uri: 'http://blog.locomotiveapp.org' }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org/api/read/json?num=3')
    end

    it 'sets auth credentials' do
      Locomotive::Httparty::Webservice.expects(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org', basic_auth: { username: 'john', password: 'foo' } }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org', { username: 'john', password: 'foo' })
    end

  end

end
