Feature: Unique fields
  As an editor
  In order to validate my data
  I want to be able to create unique fields

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Members" with
    | label         | type      | required    | unique  |
    | Name          | string    | true        | false   |
    | e-mail        | email     | true        | true    |
  And I have entries for "Members" with
    | name              | e_mail        |
    | John Doe          | john@doe.com |
    
  And I am an authenticated user

@javascript
Scenario:
  And I go to the list of "Members"
  And I follow "new entry" within the main content
  And I fill in "Name" with "John Doe II"
  And I fill in "e-mail" with "john@doe.com"
  And I press "Create"
  Then I should see "Entry was not created."

  When I fill in "e-mail" with "john@doe.es"
  And I press "Create"
  Then I should see "Entry was successfully created."