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
    Then the JSON response should be the following:
    """
    {
      "error": "You need to sign in or sign up before continuing."
    }
    """

  # listing pages

  Scenario: Accessing pages as an Admin
    Given I have an "admin" token
    When I do an API GET request to pages.json
    Then the JSON response should contain all pages

  Scenario: Accessing pages as a Designer
    Given I have a "designer" token
    When I do an API GET request to pages.json
    Then the JSON response should contain all pages

  Scenario: Accessing pages as an Author
    Given I have an "author" token
    When I do an API GET request to pages.json
    Then the JSON response should contain all pages

  # showing page

  Scenario: Accessing page as an Admin
    Given I have an "admin" token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "slug": "hello-world"
    }
    """

  Scenario: Accessing page as a Designer
    Given I have a "designer" token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "slug": "hello-world"
    }
    """

  Scenario: Accessing page as an Author
    Given I have an "author" token
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "slug": "hello-world"
    }
    """

  # create page

  Scenario: Creating new page as an Admin
    Given I have an "admin" token
    When I do an API GET request to pages.json
    Then the JSON response should contain 4 pages
    And the JSON response should contain all pages
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_id": "4f832c2cb0d86d3f42fffffe"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should contain 5 pages
    And the JSON response should contain all pages

  Scenario: Creating new page as a Designer
    Given I have a "designer" token
    When I do an API GET request to pages.json
    Then the JSON response should contain 4 pages
    And the JSON response should contain all pages
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_id": "4f832c2cb0d86d3f42fffffe"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should contain 5 pages
    And the JSON response should contain all pages

  Scenario: Creating new page as an Author
    Given I have an "author" token
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "slug": "new-page",
        "parent_id": "4f832c2cb0d86d3f42fffffe"
      }
    }
    """
    Then the JSON response should be an access denied error

  # update page

  Scenario: Updating page as an Admin
    Given I have an "admin" token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "title": "Brand new updated title"
    }
    """

  Scenario: Updating page as a Designer
    Given I have a "designer" token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "title": "Brand new updated title"
    }
    """

  Scenario: Updating page as an Author
    Given I have a "author" token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "title": "Brand new updated title"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response hash should contain:
    """
    {
      "id": "4f832c2cb0d86d3f42fffffe",
      "title": "Brand new updated title"
    }
    """
