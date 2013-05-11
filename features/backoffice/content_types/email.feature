Feature: Email fields
  As an editor
  In order to validate my data
  I want to be able to create email fields

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Members" with
    | label         | type      | required    |
    | Name          | string    | true        |
    | e-mail        | email     | true        |
    
  And I am an authenticated user

@javascript
Scenario:
  And I go to the list of "Members"
  And I follow "new entry" within the main content
  And I fill in "Name" with "John Doe"
  And I fill in "e-mail" with "fake"
  And I press "Create"
  Then I should see "Entry was not created."

  When I fill in "e-mail" with "john@doe.com"
  And I press "Create"
  Then I should see "Entry was successfully created."