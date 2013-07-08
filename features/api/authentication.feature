Feature: Authentication
  In order to consume the API
  As an admin
  I need to get an authentication token

  Background:
    Given I have the site: "test site" set up

  Scenario: Fail to get a token without an email and a password
    When I post to "/locomotive/api/tokens.json"
    Then the JSON response at "message" should be "The request must contain either the user email and password OR the API key."

  Scenario: Fail to get a token with a wrong password
    When I post to "/locomotive/api/tokens.json" with:
    """
    { "email": "admin@locomotiveapp.org", "password": "wrongone" }
    """
    Then the JSON response at "message" should be "Invalid email or password."

  Scenario: Fail to get a token with a wrong api key
    When I post to "/locomotive/api/tokens.json" with:
    """
    { "api_key": "42" }
    """
    Then the JSON response at "message" should be "The API key is invalid."

  Scenario: Get a token from an email and password
    When I post to "/locomotive/api/tokens.json" with:
    """
    { "email": "admin@locomotiveapp.org", "password": "easyone" }
    """
    Then the JSON response at "token" should be a string
    And the JSON response should not have "message"

  Scenario: Get a token from an API key
    When I post to "/locomotive/api/tokens.json" with:
    """
    { "api_key": "d49cd50f6f0d2b163f48fc73cb249f0244c37074" }
    """
    Then the JSON response at "token" should be a string
    And the JSON response should not have "message"