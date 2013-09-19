Feature: Manage Pages
  In order to manage pages
  As an administrator
  I want to add/edit/delete pages of my site

Background:
  Given I have the site: "test site" set up with name: "test site", timezone_name: "Paris"
  And I am an authenticated user

Scenario: Pages list is not accessible for non authenticated accounts
  Given I am not authenticated
  When I go to pages
  Then I should see "You need to sign in or sign up before continuing"

Scenario: Templatized pages are avaiable to authors
  Given I am not authenticated
  And I am an authenticated "author"
  And I have a custom model named "Articles" with
      | label       | type      | required    |
      | Title       | string    | true        |
  And I have entries for "Articles" with
    | title             |
    | Hello world       |
  And a templatized page for the "Articles" model and with the template:
    """
    Here is the title: "{{ article.title }}"
    """
  When I go to pages
  Then I should see "Template for Articles"

@javascript
Scenario: Creating a valid page
  When I go to pages
  And I follow "new page" within the main content
  And I fill in "page_title" with "Test"
  And I fill in "Slug" with "test"
  And I select "Home page" from "Parent"
  And I sync my form with my backbone model because of Firefox
  And I press "Create"
  Then I should see "Page was successfully created."
  And I should have "{% extends 'parent' %}" in the test page

@javascript
Scenario: Updating a valid page
  When I go to pages
  And I follow "Home page" within the main content
  And I change the page title to "Home page !"
  And I change the page template to "My new content is here"
  And I press "Save"
  Then I should see "Page was successfully updated."
  Then I go to pages
  And updated_at of the index page should respect site's timezone
  And I should have "My new content is here" in the index page

@javascript
Scenario: Localizing page slugs
  Given the site "test site" has locales "en, es"
  When I go to pages
  And I follow "new page" within the main content
  And I fill in "page_title" with "Translated"
  And I wait 1500ms
  And I press "Create"
  Then I should see "Page was successfully created."
  And I should see a "show" link to "/translated"

  When I switch the locale to "es"
  And I fill in "Slug" with "pagina-traducida"
  And I wait 1500ms
  Then I should see "/es/pagina-traducida"

  When I press "Save"
  Then I should see a "show" link to "/es/pagina-traducida"

