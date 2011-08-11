Feature: Set up a has many reverse relationship
  In order to have a true 1:N relationship between 2 content types
  As an administrator
  I want to set up a reverse a has many relationship

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Clients" with
    | label       | kind      | required    |
    | Name        | string    | true        |
    | Description | string    | false       |
  And I have a custom model named "Projects" with
    | label       | kind      | required    | target  |
    | Name        | string    | true        |         |
    | Description | text      | false       |         |
    | Client      | has_one   | false       | Clients |
  And I set up a reverse has_many relationship between "Clients" and "Projects"
  And I have entries for "Clients" with
    | name              | description             |
    | Apple Inc         | Lorem ipsum             |
    | NoCoffee          | Lorem ipsum...          |
  And I have entries for "Projects" with
    | name              | description             |
    | My sexy project   | Lorem ipsum             |
    | Foo project       | Lorem ipsum...          |
    | Bar project       | Lorem ipsum...          |

  And I am an authenticated user

@javascript
Scenario: I do not see the "Add Item" button for new parent
  When I go to the "Clients" model creation page
  Then "New item" should not be an option for "label"

@javascript
Scenario: I attach already created items for an existing parent and save it
  When I go to the "Clients" model list page
  And I follow "Apple Inc"
  And I wait until ".has-many-selector ul li.template" is visible
  Then "My sexy project" should be an option for "label"
  When I select "My sexy project" from "label"
  And I press "+ add"
  And "My sexy project" should not be an option for "label"
  When I press "Save"
  And I wait until ".has-many-selector ul li.template" is visible
  Then "My sexy project" should not be an option for "label"

@javascript
Scenario: I create a new item and attach it
  When I go to the "Clients" model list page
  And I follow "Apple Inc"
  And I wait until ".has-many-selector ul li.template" is visible
  And I press "+ add"
  Then I should see "Apple Inc » Projects — new item"
  And I should not see "Client" within the main form
  When I fill in "Name" with "iPad"
  And I press "Create"
  Then I should see "Content was successfully created."
  When I wait until ".has-many-selector ul li.template" is visible
  Then I should see "iPad"
  And "iPad" should not be an option for "label"
