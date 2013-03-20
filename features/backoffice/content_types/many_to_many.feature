Feature: Set up a many to many relationship
  In order to have a N:N relationship between 2 content types
  As an administrator
  I want to set up a many to many relationship

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Articles" with
    | label       | type      | required    |
    | Title       | string    | true        |
    | Body        | string    | false       |
  And I have a custom model named "Projects" with
    | label       | type      | required    | target  |
    | Name        | string    | true        |         |
    | Description | text      | false       |         |
  And I set up a many_to_many relationship between "Articles" and "Projects"
  And I have entries for "Articles" with
    | title             | body                    |
    | Hello world       | Lorem ipsum             |
    | Lorem ipsum       | Lorem ipsum...          |
  And I have entries for "Projects" with
    | name              | description             |
    | My sexy project   | Lorem ipsum             |
    | Foo project       | Lorem ipsum...          |
    | Bar project       | Lorem ipsum...          |

  And I am an authenticated user

@javascript
Scenario: I attach projects to an article
  When I go to the list of "Articles"
  And I choose "Hello world" in the list
  Then I should see "The list is empty. Add an entry from the select box below."
  When I select "My sexy project" from "entry"
  And I follow "+ add"
  Then I should see "My sexy project" within the list of entries
  And "p.empty" should not be visible within the list of entries
  When I press "Save"
  Then I should see "Entry was successfully updated."
  When I go to the list of "Projects"
  And I choose "My sexy project" in the list
  Then I should see "Hello world" within the list of entries