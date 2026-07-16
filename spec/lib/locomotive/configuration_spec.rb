require 'spec_helper'

describe Locomotive::Configuration do

  before { @old_config = Locomotive.config.dup }

  it 'allows a different value for the reserved site handles' do
    expect(Locomotive.config.reserved_site_handles.include?('sites')).to eq(true) # by default
    Locomotive.config.reserved_site_handles = %w(empty)
    expect(Locomotive.config.reserved_site_handles).to eq(['empty'])
  end

  it 'allows site notifications to use the application delivery method by default' do
    expect(Locomotive.config.allow_site_notifications_via_application_delivery_method).to eq(true)
  end

  after { Locomotive.config = @old_config }

end
