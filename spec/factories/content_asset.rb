# encoding: utf-8

FactoryBot.define do

  ## Assets ##
  factory :asset, class: Locomotive::ContentAsset do
    source { Rack::Test::UploadedFile.new(File.join(Rails.root, '..', '..', 'spec', 'fixtures', 'images', 'rails.png'))}
    site { Locomotive::Site.where(handle: 'acme').first || create(:site) }
  end

end
