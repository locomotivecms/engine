Then /^I should see the role dropdown on the "([^"]*)"$/ do |user|
  find(:css, "li.membership[data-role=#{user}] select").should be_present
end

Then /^I should see the role dropdown on the "([^"]*)" without the "([^"]*)" option$/ do |user, option|
  find(:css, "li.membership[data-role=#{user}] select").text.should_not include option
end

Then /^I should see the role dropdown on myself$/ do
  step %{I should see the role dropdown on the "#{@member.role}"}
end

Then /^I should not see the role dropdown on the "([^"]*)"$/ do |user|
  page.has_css?("li.membership[data-role=#{user}] select").should be_false
end

Then /^I should not see the role dropdown on myself$/ do
  step %{I should not see the role dropdown on the "#{@member.role}"}
end

Then /^I should not see any role dropdowns$/ do
  page.has_css?('li.membership select').should be_false
end

Then /^I should see delete on the "([^"]*)"$/ do |role|
  page.has_css?("li.membership[data-role=#{role}] .actions a.remove").should be_true
end

Then /^I should not see delete on the "([^"]*)"$/ do |role|
  page.has_css?("li.membership[data-role=#{role}] .actions a.remove").should be_false
end

Then /^I should not see delete on myself$/ do
  step %{I should not see delete on the "#{@member.role}"}
end

Then /^I should not see any delete buttons$/ do
 page.has_css?('li.membership .actions a.remove').should be_false
end

When /^I select the "([^"]*)" role for the "author" user/ do |role|
  step %{I select "#{role}" from "site[memberships_attributes][2][role]"}
end
