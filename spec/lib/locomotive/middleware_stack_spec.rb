require 'rails_helper'

describe 'Locomotive middleware stack' do

  let(:names) { Rails.application.middleware.map(&:name) }

  it 'inserts ImageThumbnail immediately after Rack::Runtime, inside the executor lifecycle' do
    runtime_index   = names.index('Rack::Runtime')
    thumbnail_index = names.index('Locomotive::Middlewares::ImageThumbnail')
    executor_index  = names.index('ActionDispatch::Executor')

    expect([runtime_index, thumbnail_index, executor_index]).to all(be_present)
    expect(thumbnail_index).to eq(runtime_index + 1)
    expect(thumbnail_index).to be > executor_index
  end

end
