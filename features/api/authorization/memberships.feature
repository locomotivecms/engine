Feature: Memberships
  In order to ensure memberships are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"
    And I have accounts:
      | email           | id                        |
      | new-user@a.com  | 4f832c2cb0d86d3f42fffffc  |
    And I have memberships:
      | email           | role      | id                        |
      | admin@a.com     | admin     | 4f832c2cb0d86d3f42fffffd  |
      | designer@a.com  | designer  | 4f832c2cb0d86d3f42fffffe  |
      | author@a.com    | author    | 4f832c2cb0d86d3f42ffffff  |

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to memberships.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing memberships

  Scenario: Accessing memberships as an Admin
    Given I have an "admin" API token
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries

  Scenario: Accessing memberships as a Designer
    Given I have a "designer" API token
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries

  Scenario: Accessing memberships as an Author
    Given I have an "author" API token
    When I do an API GET request to memberships.json
    Then an access denied error should occur

  # showing membership

  Scenario: Accessing membership as an Admin
    Given I have an "admin" API token
    When I do an API GET request to memberships/4f832c2cb0d86d3f42fffffd.json
    Then the JSON response at "email" should be "admin@a.com"
    When I do an API GET request to memberships/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "email" should be "designer@a.com"
    When I do an API GET request to memberships/4f832c2cb0d86d3f42ffffff.json
    Then the JSON response at "email" should be "author@a.com"

  Scenario: Accessing membership as a Designer
    Given I have a "designer" API token
    When I do an API GET request to memberships/4f832c2cb0d86d3f42fffffd.json
    Then the JSON response at "email" should be "admin@a.com"
    When I do an API GET request to memberships/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "email" should be "designer@a.com"
    When I do an API GET request to memberships/4f832c2cb0d86d3f42ffffff.json
    Then the JSON response at "email" should be "author@a.com"

  Scenario: Accessing membership as an Author
    Given I have an "author" API token
    When I do an API GET request to memberships/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur

  # create membership

  Scenario: Creating new membership as an Admin
    Given I have an "admin" API token
    When I do an API POST to memberships.json with:
    """
    {
      "membership": {
        "site_id": "4f832c2cb0d86d3f42fffffb",
        "account_id": "4f832c2cb0d86d3f42fffffc"
      }
    }
    """
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  Scenario: Creating new membership as a Designer
    Given I have a "designer" API token
    When I do an API POST to memberships.json with:
    """
    {
      "membership": {
        "site_id": "4f832c2cb0d86d3f42fffffb",
        "account_id": "4f832c2cb0d86d3f42fffffc"
      }
    }
    """
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  Scenario: Creating new membership as an Author
    Given I have an "author" API token
    When I do an API POST to memberships.json with:
    """
    {
      "membership": {
        "site_id": "4f832c2cb0d86d3f42fffffb",
        "account_id": "4f832c2cb0d86d3f42fffffc"
      }
    }
    """
    Then an access denied error should occur

  Scenario: Created membership should always be Author
    Given I have an "admin" API token
    When I do an API POST to memberships.json with:
    """
    {
      "membership": {
        "site_id": "4f832c2cb0d86d3f42fffffb",
        "account_id": "4f832c2cb0d86d3f42fffffc",
        "role": "admin"
      }
    }
    """
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries
    And the JSON at "4/role" should be "author"

  # update membership

  Scenario: Updating membership as an Admin
    Given I have an "admin" API token
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "admin"
      }
    }
    """
    When I do an API GET request to memberships/4f832c2cb0d86d3f42ffffff.json
    Then the JSON response at "role" should be "admin"

  Scenario: Updating membership as a Designer
    Given I have a "designer" API token
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "admin"
      }
    }
    """
    When I do an API GET request to memberships/4f832c2cb0d86d3f42ffffff.json
    Then the JSON response at "role" should be "author"
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "designer"
      }
    }
    """
    When I do an API GET request to memberships/4f832c2cb0d86d3f42ffffff.json
    Then the JSON response at "role" should be "designer"

  Scenario: Updating membership as an Author
    Given I have a "author" API token
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "admin"
      }
    }
    """
    Then an access denied error should occur
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "designer"
      }
    }
    """
    Then an access denied error should occur
    When I do an API PUT to memberships/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "membership": {
        "role": "author"
      }
    }
    """
    Then an access denied error should occur

  # destroy membership

  Scenario: Destroying membership as an Admin
    Given I have an "admin" API token
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API DELETE to memberships/4f832c2cb0d86d3f42ffffff.json
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries

  Scenario: Destroying membership as a Designer
    Given I have a "designer" API token
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 4 entries
    When I do an API DELETE to memberships/4f832c2cb0d86d3f42ffffff.json
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    When I do an API DELETE to memberships/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
    When I do an API DELETE to memberships/4f832c2cb0d86d3f42fffffd.json
    Then an access denied error should occur

  Scenario: Deleting membership as an Author
    Given I have a "author" API token
    When I do an API DELETE to memberships/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
