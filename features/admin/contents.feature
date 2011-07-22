Feature: Manage Contents
  In order to manage instances from custom content types
  As an administrator
  I want to add/edit/delete custom contents of my site

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | kind      | required        |
    | Name        | string    | true            |
    | Description | text      | false           |
    | Category    | category  | false           |
  And I have "Design, Development" as "Category" values of the "Projects" model
  And I am an authenticated user
  And I have entries for "Projects" with
    | name              | description             | category        |
    | My sexy project   | Lorem ipsum             | Development     |
    | Foo project       | Lorem ipsum...          | Design          |
    | Bar project       | Lorem ipsum...          | Design          |

Scenario:
  When I go to the "Projects" model list page
  Then I should see "My sexy project"

Scenario: Add a new entry
  When I go to the "Projects" model edition page
  And I follow "new item"
  Then I should see "Projects — new item"
  When I fill in "Name" with "My other sexy project"
  And I fill in "Description" with "Lorem ipsum...."
  And I press "Create"
  Then I should see "Content was successfully created."

Scenario: Add an invalid entry
  When I go to the "Projects" model edition page
  And I follow "new item"
  And I fill in "Description" with "Lorem ipsum...."
  And I press "Create"
  Then I should not see "Content was successfully created."

Scenario: Update an existing entry
  When I go to the "Projects" model list page
  And I follow "My sexy project"
  When I fill in "Name" with "My other sexy project (UPDATED)"
  And I press "Save"
  Then I should see "Content was successfully updated."
  When I go to the "Projects" model list page
  Then I should see "My other sexy project (UPDATED)"

Scenario: Update an invalid entry
  When I go to the "Projects" model list page
  And I follow "My sexy project"
  When I fill in "Name" with ""
  And I press "Save"
  Then I should not see "Content was successfully updated."

Scenario: Destroy an entry
  When I go to the "Projects" model list page
  And I follow image link "Delete"
  Then I should see "Content was successfully deleted."
  And I should not see "My sexy project"

Scenario: Group entries by category
  When I go to the "Projects" model list page
  Then I should not see "Development"
  And I should not see "Design"
  When I change the presentation of the "Projects" model by grouping items by "Category"
  And I go to the "Projects" model list page
  Then I should see "Development"
  And I should see "Design"