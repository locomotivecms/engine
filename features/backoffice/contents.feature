Feature: Manage Contents
  In order to manage instances from custom content types
  As an administrator
  I want to add/edit/delete custom contents of my site

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | type      | required        |
    | Name        | string    | true            |
    | Description | text      | false           |
    | Category    | select    | false           |
  And I have "Design, Development" as "Category" values of the "Projects" model
  And I am an authenticated user
  And I have entries for "Projects" with
    | name              | description             | category        |
    | My sexy project   | Lorem ipsum             | Development     |
    | Foo project       | Lorem ipsum...          | Design          |
    | Bar project       | Lorem ipsum...          | Design          |
    | Other project #1  | Lorem ipsum...          | Design          |
    | Other project #2  | Lorem ipsum...          | Design          |
    | Other project #3  | Lorem ipsum...          | Design          |

Scenario: Listing content entries
  When I go to the list of "Projects"
  Then I should see "My sexy project"
  And I should see "Other project #2"
  And I should see "Other project #3"

Scenario: Listing content entries without pagination
  When I change the number of items to display per page to 4
  And I go to the list of "Projects"
  Then I should see "Other project #2"
  And I should see "Other project #3"

Scenario: Listing content entries with pagination
  When I change the number of items to display per page to 4
  And the custom model named "Projects" is ordered by "name"
  And I go to the list of "Projects"
  Then I should not see "Other project #2"
  And I should not see "Other project #3"

Scenario: Add a new entry
  When I go to the list of "Projects"
  And I follow "new entry" within the main content
  Then I should see "Projects — new entry"
  When I fill in "Name" with "My other sexy project"
  And I fill in "Description" with "Lorem ipsum...."
  And I press "Create"
  Then I should see "Entry was successfully created." in the html code

Scenario: Add an invalid entry
  When I go to the list of "Projects"
  And I follow "new entry" within the main content
  And I fill in "Description" with "Lorem ipsum...."
  And I press "Create"
  Then I should not see "Entry was successfully created." in the html code

Scenario: Update an existing entry
  When I go to the list of "Projects"
  And I follow "My sexy project" within the main content
  When I fill in "Name" with "My other sexy project (UPDATED)"
  And I press "Save" within the main form
  Then I should see "Entry was successfully updated." in the html code
  When I go to the list of "Projects"
  Then I should see "My other sexy project (UPDATED)"

Scenario: Update an invalid entry
  When I go to the list of "Projects"
  And I follow "My sexy project" within the main content
  When I fill in "Name" with ""
  And I press "Save" within the main form
  Then I should not see "Entry was successfully updated." in the html code

Scenario: Destroy an entry
  When I go to the list of "Projects"
  And I delete the first content entry
  Then I should see "Entry was successfully deleted." in the html code
  And I should not see "My sexy project"

Scenario: Export list of entries
  When I go to the list of "Projects"
  And I follow "Export"
  Then I should get a download with the filename "projects.csv"

Scenario: Group entries by category
  When I go to the list of "Projects"
  Then I should not see "Development"
  And I should not see "Design"
  When I change the presentation of the "Projects" model by grouping items by "Category"
  And I go to the list of "Projects"
  Then I should see "Development"
  And I should see "Design"