require 'spec_helper'

describe 'Enable SSL admin' do
  before :each do
    FactoryGirl.create('existing site')
    FactoryGirl.create(:account)
    host!('models.example.com')
  end

  it 'should redirect to SSL on admin when enabled' do
    Locomotive.config.enable_admin_ssl = true

    get '/locomotive/pages'
    response.status.should == 302
    response.location.should =~ /https/
  end

  it 'should not redirect to SSL on admin when disabled' do
    Locomotive.config.enable_admin_ssl = false

    get '/locomotive/pages'
    response.status.should == 302
    response.location.should =~ /http/
  end
end