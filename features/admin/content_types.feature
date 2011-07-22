Feature: Manage Content Types
  In order to manage custom content models
  As an administrator
  I want to add/edit/delete custom models of my site

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | kind      | required        |
    | Name        | string    | true            |
    | Description | text      | false           |
  And I am an authenticated user

@javascript
Scenario: I do not want my content form to have n duplicated fields if I submit n times the content type form with errors (bug)
  When I go to the "Projects" model edition page
  And I fill in "Name" with ""
  And I press "Save"
  And I press "Save"
  And I press "Save"
  When I follow "new item"
  Then I should see once the "Name" field
