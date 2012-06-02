Feature: Current Site
  In order to ensure the current site can be viewed by all authenticated users
  As an admin, designer or author
  I should be able to show the current site

  Background:
    Given I have the site: "test site" set up
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to current_site.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # showing current site

  Scenario: Accessing current site as an Admin
    Given I have an "admin" API token
    When I do an API GET to current_site.json
    Then the JSON response at "name" should be "Locomotive test website"

  Scenario: Accessing current site as a Designer
    Given I have a "designer" API token
    When I do an API GET to current_site.json
    Then the JSON response at "name" should be "Locomotive test website"

  Scenario: Accessing current site as an Author
    Given I have an "author" API token
    When I do an API GET to current_site.json
    Then the JSON response at "name" should be "Locomotive test website"
