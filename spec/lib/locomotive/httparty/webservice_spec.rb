require 'spec_helper'

describe Locomotive::Httparty::Webservice do

  context '#consuming' do

    before(:each) do
      @response = mock('response', code: 200, parsed_response: OpenStruct.new)
    end

    it 'sets the base uri from a simple url' do
      Locomotive::Httparty::Webservice.expects(:get).with('/', base_uri: 'http://blog.locomotiveapp.org').returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org')
    end

    it 'sets the base uri from a much more complex url' do
      Locomotive::Httparty::Webservice.expects(:get).with('/feed/weather.ashx', base_uri: 'http://free.worldweatheronline.com', query: { 'key' => 'secretapikey', 'format' => 'json' }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://free.worldweatheronline.com/feed/weather.ashx?key=secretapikey&format=json')
    end

    it 'sets both the base uri and the path from an url with parameters' do
      Locomotive::Httparty::Webservice.expects(:get).with('/api/read/json', base_uri: 'http://blog.locomotiveapp.org', query: { 'num' => '3' }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org/api/read/json?num=3')
    end

    it 'sets auth credentials' do
      Locomotive::Httparty::Webservice.expects(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org', basic_auth: { username: 'john', password: 'foo' } }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org', { username: 'john', password: 'foo' })
    end

    it 'sends a post request' do
      Locomotive::Httparty::Webservice.expects(:post).with('/api/charge.json', { base_uri: 'http://blog.locomotiveapp.org', body: { 'source' => 'abc', 'amount' => '42000' } }).returns(@response)
      Locomotive::Httparty::Webservice.consume('http://blog.locomotiveapp.org/api/charge.json?source=abc&amount=42000', method: :post)
    end

  end

  context 'in a real-world' do

    it 'works as well' do
      response = Locomotive::Httparty::Webservice.consume('https://api.github.com/users/did/repos', { format: "'json'", with_user_agent: true })
      response.size.should_not eq 0
    end

  end

end
