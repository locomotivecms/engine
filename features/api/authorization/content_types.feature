Feature: Content Types
  In order to ensure content types are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And I have a custom model named "Projects" with id "4f832c2cb0d86d3f42fffffe" and
      | label       | type      | required        |
      | Name        | string    | true            |
      | Description | text      | false           |
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to content_types.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing content types

  Scenario: Accessing content types as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing content types as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing content types as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  # showing content type

  Scenario: Accessing content type as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Projects"

  Scenario: Accessing content type as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Projects"

  Scenario: Accessing content type as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Projects"

  # create content type

  Scenario: Creating new content type as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Position",
            "name": "position",
            "type": "string"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON should have the following:
      | 0/name                          | "Employees"   |
      | 0/slug                          | "employees"   |
      | 0/entries_custom_fields/0/label | "Name"        |
      | 0/entries_custom_fields/0/name  | "name"        |
      | 0/entries_custom_fields/0/type  | "string"      |
      | 0/entries_custom_fields/1/label | "Position"    |
      | 0/entries_custom_fields/1/name  | "position"    |
      | 0/entries_custom_fields/1/type  | "string"      |

  Scenario: Creating new content type as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Position",
            "name": "position",
            "type": "string"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON should have the following:
      | 0/name                          | "Employees"   |
      | 0/slug                          | "employees"   |
      | 0/entries_custom_fields/0/label | "Name"        |
      | 0/entries_custom_fields/0/name  | "name"        |
      | 0/entries_custom_fields/0/type  | "string"      |
      | 0/entries_custom_fields/1/label | "Position"    |
      | 0/entries_custom_fields/1/name  | "position"    |
      | 0/entries_custom_fields/1/type  | "string"      |

  Scenario: Creating new content type as an Author
    Given I have an "author" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Position",
            "name": "position",
            "type": "string"
          }
        ]
      }
    }
    """
    Then an access denied error should occur

  # update content type

  Scenario: Updating content type as an Admin
    Given I have an "admin" API token
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating content type as a Designer
    Given I have a "designer" API token
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating content type as an Author
    Given I have a "author" API token
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "name": "Brand new updated name"
      }
    }
    """
    Then an access denied error should occur

  # destroy content type

  Scenario: Destroying content type as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API DELETE to content_types/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Destroying content type as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API DELETE to content_types/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Deleting content type as an Author
    Given I have a "author" API token
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entries
    When I do an API DELETE to content_types/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
