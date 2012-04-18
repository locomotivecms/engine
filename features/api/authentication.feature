Feature: Authentication
  In order to consume the API
  As an admin
  I need to get an authentication token

  Background:
    Given I have the site: "test site" set up

  Scenario: Fail to get a token without an email and a password
    When I post to "/locomotive/api/tokens.json"
    Then the JSON response at "message" should be "The request must contain the user email and password."

  Scenario: Get a token
    When I post to "/locomotive/api/tokens.json" with:
    """
    { "email": "admin@locomotiveapp.org", "password": "easyone" }
    """
    Then the JSON response at "token" should be a string
    And the JSON response should not have "message"