require 'spec_helper'

describe Locomotive::Configuration do

  before(:each) do
    @old_config = Locomotive.config.dup
  end

  it 'allows a different value for the reserved subdomains' do
    Locomotive.config.reserved_subdomains.include?('www').should be_true # by default
    Locomotive.config.multi_sites { |multi_sites| multi_sites.reserved_subdomains = %w(empty) }
    Locomotive.config.reserved_subdomains.should == ['empty']
  end

  after(:each) do
    Locomotive.config = @old_config
  end

end