
Given /^I have accounts:$/ do |accounts_table|
  accounts_table.hashes.each do |account_hash|
    FactoryGirl.create(:account, account_hash)
  end
end

Given /^I have memberships:$/ do |members_table|
  members_table.hashes.each do |member_hash|
    email = member_hash[:email]
    account = Locomotive::Account.where(:email => email).first \
      || FactoryGirl.create(:account, :email => email)

    member_hash.delete(:email)
    member_hash.merge!({ :account => account, :site => @site })

    FactoryGirl.create(:membership, member_hash)
  end
end
