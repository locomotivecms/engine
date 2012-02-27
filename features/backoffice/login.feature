Feature: Log in
  In order to access locomotive admin panel
  As an administrator
  I want to log in

Background:
  Given I have the site: "test site" set up

Scenario: Successfully logging in
  When I go to login
  And I fill in "Email" with "admin@locomotiveapp.org"
  And I fill in "Password" with "easyone"
  And I press "Log in"
  Then I should see "Listing pages"

Scenario: Attempting to login with an invalid emai or password
  When I go to login
  And I fill in "Email" with "admin@locomotiveapp.org"
  And I fill in "Password" with ""
  And I press "Log in"
  Then I should not see "Listing pages"
  And I should see "Invalid email or password"

Scenario: Attempting to login with an account without a membership
  Given the following accounts exist:
   | email                  | password      | password_confirmation |
   | john@locomotiveapp.org | bluecheese    | bluecheese            |
  When I go to login
  And I fill in "Email" with "john@locomotiveapp.org"
  And I fill in "Password" with "bluecheese"
  And I press "Log in"
  Then I should not see "Listing pages"
  And I should see "not a member of this site"
