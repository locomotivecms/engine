When /^I follow image link "([^"]*)"$/ do |img_alt|
    find(:xpath, "//img[@alt = '#{img_alt}']/parent::a").click()
end

Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end