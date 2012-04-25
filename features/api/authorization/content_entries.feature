Feature: Content Entries
  In order to ensure content entries are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And I have a custom model named "Projects" with
      | label       | type      | required        |
      | Name        | string    | true            |
      | Description | text      | false           |
    And I have entries for "Projects" with
      | id                          | name        | description           |
      | 4f832c2cb0d86d3f42fffffe    | Project 1   | The first project     |
      | 4f832c2cb0d86d3f42ffffff    | Project 2   | The second project    |
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to content_types/projects/entries.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing content entries

  Scenario: Accessing content entries as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing content entries as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing content entries as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  # showing content entry

  Scenario: Accessing content entry as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Project 1"

  Scenario: Accessing content entry as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Project 1"

  Scenario: Accessing content entry as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Project 1"

  # create content entry

  Scenario: Creating new content entry as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "description": "The third..."
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/name          | "Project 3"       |
      | 2/description   | "The third..."    |

  Scenario: Creating new content entry as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "description": "The third..."
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/name          | "Project 3"       |
      | 2/description   | "The third..."    |

  Scenario: Creating new content entry as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "description": "The third..."
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/name          | "Project 3"       |
      | 2/description   | "The third..."    |

  # update content entry

  Scenario: Updating content entry as an Admin
    Given I have an "admin" API token
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_entry": {
        "description": "The awesomest project ever!"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Project 1"
    And the JSON response at "description" should be "The awesomest project ever!"

  Scenario: Updating content entry as a Designer
    Given I have a "designer" API token
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_entry": {
        "description": "The awesomest project ever!"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Project 1"
    And the JSON response at "description" should be "The awesomest project ever!"

  Scenario: Updating content entry as an Author
    Given I have a "author" API token
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_entry": {
        "description": "The awesomest project ever!"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Project 1"
    And the JSON response at "description" should be "The awesomest project ever!"

  # destroy content entry

  Scenario: Destroying content entry as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Destroying content entry as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Deleting content entry as an Author
    Given I have a "author" API token
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_types/projects/entries/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
