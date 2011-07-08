Feature: Exporting a Site
  In order to use the site outside the current locomotive instance
  As an admin, designer, or author
  I will be restricted based on my role

Background:
  Given I have the site: "test site" set up
  And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to export page
    Then I should see "Log in"

  Scenario: Accessing exporting functionality as an Admin
    Given I am an authenticated "admin"
    When I go to the export page
    Then I should get a download with the filename "locomotive-test-website.zip"

  Scenario: Accessing exporting functionality as a Designer
    Given I am an authenticated "designer"
    When I go to the export page
    Then I should get a download with the filename "locomotive-test-website.zip"

  Scenario: Accessing exporting functionality as an Author
    Given I am an authenticated "author"
    When I go to the export page
    Then I should be on the pages list
    And I should see the access denied message
