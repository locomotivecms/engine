Feature: Login
  In order to access locomotive admin panel
  As an administrator
  I want to log in

Background:
  Given I have the site: "test site" set up

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