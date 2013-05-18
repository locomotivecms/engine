Feature: Tagged content
  As a designer
  In order to organize my content
  I want to be able to tag it

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Titles" with
    | label         | type      | required    |
    | Title         | string    | true        |
    | Tags          | tags      | false       |

  And I am an authenticated user

@javascript
Scenario:
  When I go to the list of "Titles"
  And I follow "new entry" within the main content
  And I fill in "Title" with "My title"
  And I fill in "Tags" with the tags "one, two, three"
  And I press "Create"
  Then I should see "Entry was successfully created."