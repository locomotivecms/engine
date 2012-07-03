Feature: Accounts
  In order to manage accounts programmatically
  As an API user
  I will be able to create and update content entries

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"

  Scenario: Setting the encrypted password on a new account
    Given I have an "admin" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "encrypted_password": "1234",
        "password_salt": "salty"
      }
    }
    """
    Then the JSON response at "encrypted_password" should be "1234"
    And the JSON response at "password_salt" should be "salty"

  Scenario: Setting the encrypted password and the password on a new account
    Given I have an "admin" API token
    When I do an API POST to accounts.json with:
    """
    {
      "account": {
        "name": "New User",
        "email": "new-user4@a.com",
        "encrypted_password": "1234",
        "password_salt": "salty",
        "password": "mypassword"
      }
    }
    """
    Then the JSON response at "encrypted_password" should be "1234"
    And the JSON response at "password_salt" should be "salty"
