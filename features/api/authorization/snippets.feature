Feature: Snippets
  In order to ensure snippets are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And a snippet named "My Snippet" with id "4f832c2cb0d86d3f42fffffe" and template:
    """
    My Snippet
    """
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to snippets.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing content types

  Scenario: Accessing snippets as an Admin
    Given I have an "admin" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing snippets as a Designer
    Given I have a "designer" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing snippets as an Author
    Given I have an "author" API token
    When I do an API GET request to snippets.json
    Then an access denied error should occur

  # showing snippet

  Scenario: Accessing snippet as an Admin
    Given I have an "admin" API token
    When I do an API GET request to snippets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "My Snippet"

  Scenario: Accessing snippet as a Designer
    Given I have a "designer" API token
    When I do an API GET request to snippets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "My Snippet"

  Scenario: Accessing snippet as an Author
    Given I have an "author" API token
    When I do an API GET request to snippets/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur

  # create snippet

  Scenario: Creating new snippet as an Admin
    Given I have an "admin" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API POST to snippets.json with:
    """
    {
      "snippet": {
        "name": "Another snippet",
        "template": "<h1>Another Snippet!</h1>"
      }
    }
    """
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON should have the following:
      | 0/name      | "Another snippet"             |
      | 0/template  | "<h1>Another Snippet!</h1>"   |

  Scenario: Creating new snippet as a Designer
    Given I have a "designer" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API POST to snippets.json with:
    """
    {
      "snippet": {
        "name": "Another snippet",
        "template": "<h1>Another Snippet!</h1>"
      }
    }
    """
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON should have the following:
      | 0/name      | "Another snippet" |
      | 0/template  | "<h1>Another Snippet!</h1>"   |

  Scenario: Creating new snippet as an Author
    Given I have an "author" API token
    When I do an API POST to snippets.json with:
    """
    {
      "snippet": {
        "name": "Another snippet",
        "template": "<h1>Another Snippet!</h1>"
      }
    }
    """
    Then an access denied error should occur

  # update snippet

  Scenario: Updating snippet as an Admin
    Given I have an "admin" API token
    When I do an API PUT to snippets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "snippet": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to snippets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating snippet as a Designer
    Given I have a "designer" API token
    When I do an API PUT to snippets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "snippet": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to snippets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating snippet as an Author
    Given I have a "author" API token
    When I do an API PUT to snippets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "snippet": {
        "name": "Brand new updated name"
      }
    }
    """
    Then an access denied error should occur

  # destroy snippet

  Scenario: Destroying snippet as an Admin
    Given I have an "admin" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API DELETE to snippets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Destroying snippet as a Designer
    Given I have a "designer" API token
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I do an API DELETE to snippets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to snippets.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Deleting snippet as an Author
    Given I have a "author" API token
    When I do an API DELETE to snippets/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
