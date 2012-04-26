
Given /^I have the following content assets:$/ do |table|
  site = Locomotive::Site.first
  table.hashes.each do |asset_hash|
    asset_hash['site'] = site
    asset_hash['source'] = FixturedAsset.open(asset_hash['file'])
    asset_hash.delete('file')

    asset = FactoryGirl.build(:asset, asset_hash)
    asset.save.should be_true
  end
end
