@site_up
Feature: Login
  In order to access locomotive admin panel
  As an administrator
  I want to log in

Scenario: Successful authentication
  When I go to login
  And I fill in "Email" with "admin@locomotiveapp.org"
  And I fill in "Password" with "easyone"
  And I press "Log in"
  Then I should see "Listing pages"

Scenario: Failed authentication
  When I go to login
  And I fill in "Email" with "admin@locomotiveapp.org"
  And I fill in "Password" with ""
  And I press "Log in"
  Then I should not see "Listing pages"