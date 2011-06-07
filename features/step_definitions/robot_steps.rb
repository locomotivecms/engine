### robots.txt

# sets the robot_txt for a site

Given /^a robot_txt set to "([^"]*)"$/ do |value|
  @site.update_attributes(:robots_txt => value)
end


