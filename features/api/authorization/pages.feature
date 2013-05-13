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
    And a page named "hello-world" with id "4f832c2cb0d86d3f42fffffe"
    And a page named "goodbye-world" with id "4f832c2cb0d86d3f42ffffff"

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to pages.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing pages

  Scenario: Accessing pages as an Admin
    Given I have an "admin" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries

  Scenario: Accessing pages as a Designer
    Given I have a "designer" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries

  Scenario: Accessing pages as an Author
    Given I have an "author" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries

  # showing page

  Scenario: Accessing page as an Admin
    Given I have an "admin" API token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "slug" should be "hello-world"

  Scenario: Accessing page as a Designer
    Given I have a "designer" API token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "slug" should be "hello-world"

  Scenario: Accessing page as an Author
    Given I have an "author" API token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "slug" should be "hello-world"

  # create page

  Scenario: Creating new page as an Admin
    Given I have an "admin" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_fullpath": "index"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  Scenario: Creating new page as a Designer
    Given I have a "designer" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_fullpath": "index"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  Scenario: Creating new page as an Author
    Given I have an "author" API token
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_fullpath": "index"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  # update page

  Scenario: Updating page as an Admin
    Given I have an "admin" API token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "title" should be "Brand new updated title"

  Scenario: Updating page as a Designer
    Given I have a "designer" API token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "title" should be "Brand new updated title"

  Scenario: Updating page as an Author
    Given I have a "author" API token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "title" should be "Brand new updated title"

  # destroy page

  Scenario: Destroying page as an Admin
    Given I have an "admin" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API DELETE to pages/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries

  Scenario: Destroying page as a Designer
    Given I have a "designer" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API DELETE to pages/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries

  Scenario: Deleting page as an Author
    Given I have a "author" API token
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API DELETE to pages/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
