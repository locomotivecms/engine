Feature: Pages
  In order to ensure pages are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And I have a custom model named "Projects" with
      | label       | type      | required        |
      | Name        | string    | true            |
      | Description | text      | false           |
    And I have a designer and an author
    And a page named "hello-world" with the template:
    """
    Hello World
    """

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to pages
    Then I should see "Log in"

  # listing pages

  Scenario: Accessing pages as an Admin
    Given I am an authenticated "admin"
    When I go to pages
    Then I should see "new page"
    And I should see delete page buttons
    And I should see "new model"
    And I should see "Projects"

  Scenario: Accessing pages as a Designer
    Given I am an authenticated "designer"
    When I go to pages
    Then I should see "new page"
    And I should see delete page buttons
    And I should see "new model"
    And I should see "Projects"

  Scenario: Accessing pages as an Author
    Given I am an authenticated "author"
    When I go to pages
    Then I should see "new page"
    And I should not see delete page buttons
    And I should not see "new model"
    And I should see "Projects"

  # new page

  Scenario: Accessing new page as an Admin
    Given I am an authenticated "admin"
    When I go to the new page
    Then I should see "New page"

  Scenario: Accessing new page as a Designer
    Given I am an authenticated "designer"
    When I go to the new page
    Then I should see "New page"

  Scenario: Accessing new page as an Author
    Given I am an authenticated "author"
    When I go to the new page
    Then I should see "New page"
    And I should not see "Template"

  # edit page

  Scenario: Accessing edit page as an Admin
    Given I am an authenticated "admin"
    When I go to the "hello-world" edition page
    Then I should see "Hello world"
    And I should see "General information"
    And I should see "SEO settings"
    And I should see "Advanced options"
    And I should see "Template"

  Scenario: Accessing edit page as a Designer
    Given I am an authenticated "designer"
    When I go to the "hello-world" edition page
    Then I should see "Hello world"
    And I should see "General information"
    And I should see "SEO settings"
    And I should see "Advanced options"
    And I should see "Template"

  Scenario: Accessing edit page as an Author
    Given I am an authenticated "author"
    When I go to the "hello-world" edition page
    Then I should see "Hello world"
    And I should not see "General Information"
    And I should see "SEO settings"
    And I should see "Advanced options"
    And I should not see "Template"

