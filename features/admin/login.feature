@site_up
Feature: Login
  In order to access locomotive admin panel
  As an administrator
  I want to log in

Scenario: Successful authentication
  When I go to login
  And I fill in "admin_email" with "admin@locomotiveapp.org"
  And I fill in "admin_password" with "easyone"
  And I press "Log in"
  And Show me the page
  Then I should see "Listing pages"

Scenario: Failed authentication
  When I go to login
  And I fill in "admin_email" with "admin@locomotiveapp.org"
  And I fill in "admin_password" with ""
  And I press "Log in"
  Then I should not see "Listing pages"