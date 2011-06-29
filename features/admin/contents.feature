Feature: Manage Contents
  In order to manage instances from custom content types
  As an administrator
  I want to add/edit/delete custom contents of my site

Background:
  Given I have the site: "test site" set up
  And I have a custom project model
  And I am an authenticated user

Scenario: Adding a new entry
  When I go to the "Projects" model edition page
  And I follow "new item"
  Then I should see "Projects — new item"


