Feature: Memberships
  In order to manage memberships programmatically
  As an API user
  I will be able to create and update memberships

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"
    And I have accounts:
      | email           | id                        |
      | new-user@a.com  | 4f832c2cb0d86d3f42fffffc  |

  Scenario: Create membership by account email
    Given I have an "admin" API token
    When I do an API POST to memberships.json with:
    """
    {
      "membership": {
        "site_id": "4f832c2cb0d86d3f42fffffb",
        "email": "new-user@a.com"
      }
    }
    """
    When I do an API GET request to memberships.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON response at "1/account_id" should be "4f832c2cb0d86d3f42fffffc"
