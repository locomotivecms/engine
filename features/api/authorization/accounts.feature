Feature: Accounts
  In order to ensure accounts are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"
    And I have a designer and an author
    And I have accounts:
      | email             | id                        |
      | new-user1@a.com   | 4f832c2cb0d86d3f42fffffc  |
      | new-user2@a.com   | 4f832c2cb0d86d3f42fffffd  |
      | new-user3@a.com   | 4f832c2cb0d86d3f42fffffe  |

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET request to accounts.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing accounts

  Scenario: Accessing accounts as an Admin
    Given I have an "admin" API token
    When I do an API GET request to accounts.json
    Then the JSON response should be an array
    And the JSON response should have 6 entries

  Scenario: Accessing accounts as a Designer
    Given I have a "designer" API token
    When I do an API GET request to accounts.json
    Then an access denied error should occur

  Scenario: Accessing accounts as an Author
    Given I have an "author" API token
    When I do an API GET request to accounts.json
    Then an access denied error should occur

  # showing account

  Scenario: Accessing account as an Admin
    Given I have an "admin" API token
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffc.json
    Then the JSON response at "email" should be "new-user1@a.com"
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffd.json
    Then the JSON response at "email" should be "new-user2@a.com"
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "email" should be "new-user3@a.com"

  Scenario: Accessing account as a Designer
    Given I have a "designer" API token
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffc.json
    Then an access denied error should occur

  Scenario: Accessing account as an Author
    Given I have an "author" API token
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffc.json
    Then an access denied error should occur

  # create account

  Scenario: Creating new account as an Admin
    Given I have an "admin" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "password": "changeme"
      }
    }
    """
    When I do an API GET request to accounts.json
    Then the JSON response should be an array
    And the JSON response should have 7 entries

  Scenario: Creating new account as a Designer
    Given I have a "designer" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "password": "changeme"
      }
    }
    """
    Then an access denied error should occur

  Scenario: Creating new account as an Author
    Given I have an "author" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "password": "changeme"
      }
    }
    """
    Then an access denied error should occur

  # update account

  Scenario: Creating new account as an Admin
    Given I have an "admin" API token
    When I do an API PUT to accounts/4f832c2cb0d86d3f42fffffc.json with:
    """
    {
      "account": {
        "name": "Modified User"
      }
    }
    """
    When I do an API GET request to accounts/4f832c2cb0d86d3f42fffffc.json
    Then the JSON response should be an hash
    And the JSON response at "name" should be "Modified User"

  Scenario: Creating new account as a Designer
    Given I have a "designer" API token
    When I do an API PUT to accounts/4f832c2cb0d86d3f42fffffc.json with:
    """
    {
      "account": {
        "name": "Modified User"
      }
    }
    """
    Then an access denied error should occur

  Scenario: Creating new account as an Author
    Given I have an "author" API token
    When I do an API PUT to accounts/4f832c2cb0d86d3f42fffffc.json with:
    """
    {
      "account": {
        "name": "Modified User"
      }
    }
    """
    Then an access denied error should occur

  # destroy account

  Scenario: Destroying account as an Admin
    Given I have an "admin" API token
    When I do an API GET request to accounts.json
    Then the JSON response should be an array
    And the JSON response should have 6 entries
    When I do an API DELETE to accounts/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to accounts.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries

  Scenario: Destroying account as a Designer
    Given I have a "designer" API token
    When I do an API DELETE to accounts/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur

  Scenario: Deleting account as an Author
    Given I have a "author" API token
    When I do an API DELETE to accounts/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
