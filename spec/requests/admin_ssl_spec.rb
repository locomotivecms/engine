require 'spec_helper'

describe 'Enable SSL admin' do

  before :each do
    FactoryGirl.create('existing site')
    FactoryGirl.create(:account)
    host!('models.example.com')
    Locomotive.config.enable_admin_ssl = true
  end

  it 'should redirect to SSL on admin when enabled' do
    get '/locomotive/pages'
    expect(response.status).to eq(302)
    expect(response.location).to match(/https/)
  end

  context 'admin ssl disabled' do

    before do
      Locomotive.config.enable_admin_ssl = false
    end

    it 'should not redirect to SSL on admin when disabled' do
      get '/locomotive/pages'
      expect(response.status).to eq(302)
      expect(response.location).to match(/http/)
    end

  end

  context 'request for the non main domain' do

    before do

      host!('myexample.com')
    end

    it 'should not redirect to SSL' do
      get '/locomotive/pages'
      expect(response.status).to eq(302)
      expect(response.location).to match(/http/)
    end

  end

  after(:all) do
    Locomotive.config.enable_admin_ssl = false
  end

end
