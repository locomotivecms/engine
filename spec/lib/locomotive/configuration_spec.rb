require 'spec_helper'

describe Locomotive::Configuration do

  before(:each) do
    @old_config = Locomotive.config.dup
  end

  it 'allows a different value for the reserved subdomains' do
    expect(Locomotive.config.reserved_subdomains.include?('www')).to eq(true) # by default
    Locomotive.config.multi_sites { |multi_sites| multi_sites.reserved_subdomains = %w(empty) }
    expect(Locomotive.config.reserved_subdomains).to eq(['empty'])
  end

  it 'calls the hosting enabler if provided' do
    Rails.env.stubs(:test?).returns(false)
    Locomotive.expects(:enable_bushido).once
    Locomotive.config.hosting = { target: :bushido }
    Locomotive.enable_hosting
  end

  after(:each) do
    Locomotive.config = @old_config
  end

end
