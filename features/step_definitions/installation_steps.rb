Then /^I should not be able to see any admin user details$/ do
  page.should_not have_content @admin.email
end
