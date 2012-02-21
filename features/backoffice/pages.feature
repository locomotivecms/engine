Feature: Manage Pages
  In order to manage pages
  As an administrator
  I want to add/edit/delete pages of my site

Background:
  Given I have the site: "test site" set up
  And I am an authenticated user

Scenario: Pages list is not accessible for non authenticated accounts
  Given I am not authenticated
  When I go to pages
  Then I should see "You need to sign in or sign up before continuing"

@javascript
Scenario: Creating a valid page
  When I go to pages
  And I follow "new page"
  And I fill in "page_title" with "Test"
  And I fill in "Slug" with "test"
  And I select "Home page" from "Parent"
  And I press "Create"
  Then I should see "Page was successfully created."
  And I should have "{% extends 'parent' %}" in the test page

@javascript
Scenario: Updating a valid page
  When I go to pages
  And I follow "Home page"
  And I change the page title with "Home page !"
  And I change the page template with "My new content is here"
  And I press "Save"
  Then I should see "Page was successfully updated."
  And I should have "My new content is here" in the index page
