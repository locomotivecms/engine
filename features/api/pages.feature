Feature: Pages
  In order to access the Page resources
  As an admin
  I will perform the basic RESTFUL actions on them

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And a page named "hello world" with the template:
    """
    Hello world :-)
    """
    And a page named "goodbye-world" with the template:
    """
    Goodbye world :-(
    """

  Scenario: Protect the pages resources if not authenticated
    Given I do not have an API token
    When I visit "/locomotive/api/pages.json"
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  Scenario: Accessing pages
    When I visit "/locomotive/api/pages.json"
    Then the JSON should have the following:
      | 0/fullpath | "index"          |
      | 1/fullpath | "hello-world"    |
      | 2/fullpath | "404"            |
      | 3/fullpath | "goodbye-world"  |