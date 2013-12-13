Feature: Manage my account
  In order to manage my account
  As an administrator
  I want to edit my profile and credentials

Background:
  Given I have the site: "test site" set up with name: "test site"
  And I am an authenticated user

@javascript
Scenario: Viewing my API key
  When I go to the account settings
  And I click on the "Credentials" folder
  Then I should see "d49cd50f6f0d2b163f48fc73cb249f0244c37074"

@javascript
Scenario: Changing  my API key
  When I go to the account settings
  And I click on the "Credentials" folder
  And I should see "d49cd50f6f0d2b163f48fc73cb249f0244c37074"
  And I press "Regenerate"
  Then I should not see "d49cd50f6f0d2b163f48fc73cb249f0244c37074"
