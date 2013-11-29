Feature: Integer fields
  As an editor
  In order to validate my data
  I want to be able to set fields to integers

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "ToDos" with
    | label         | type      | required    |
    | Task          | string    | true        |
    | Priority      | integer   | true        |

  And I am an authenticated user

@javascript
Scenario:
  And I go to the list of "ToDos"
  And I follow "new entry" within the main content
  And I fill in "Task" with "Buy milk"
  And I fill in "Priority" with "one"
  And I press "Create"
  Then I should see "Entry was not created."

  When I fill in "Priority" with "1"
  And I press "Create"
  Then I should see "Entry was successfully created."