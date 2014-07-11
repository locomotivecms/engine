Feature: Accounts
  In order to manage accounts programmatically
  As an API user
  I will be able to create and update content entries

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"

  Scenario: Creating a new account
    Given I have an "admin" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "password": "asimpleone",
        "password_confirmation": "asimpleone"
      }
    }
    """
    When I do an API GET request to accounts.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON response at "1/name" should be "New User"

  Scenario: Updating a account
    Given I have an "admin" API token
    And I have accounts:
      | name | email           | id                       |
      | User | new-user1@a.com | 4f832c2cb0d86d3f42fffffc |

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
