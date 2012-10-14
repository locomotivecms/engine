Feature: Sites
  In order to ensure sites are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffe"
    And I have the site: "another site" set up with id: "4f832c2cb0d86d3f42ffffff"
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to sites.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing sites

  Scenario: Accessing sites as an Admin
    Given I have an "admin" API token
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing sites as a Designer
    Given I have a "designer" API token
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing sites as an Author
    Given I have an "author" API token
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  # showing site

  Scenario: Accessing site as an Admin
    Given I have an "admin" API token
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Locomotive test website"

  Scenario: Accessing my site as a Designer
    Given I have a "designer" API token
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Locomotive test website"

  Scenario: Accessing other site as a Designer
    Given I have a "designer" API token
    When I do an API GET request to sites/4f832c2cb0d86d3f42ffffff.json
    # Then I print the json response
    Then an access denied error should occur

  Scenario: Accessing my site as an Author
    Given I have an "author" API token
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "name" should be "Locomotive test website"

  Scenario: Accessing other site as an Author
    Given I have an "author" API token
    When I do an API GET request to sites/4f832c2cb0d86d3f42ffffff.json
    Then an access denied error should occur

  # create site

  Scenario: Creating new site as an Admin
    Given I have an "admin" API token
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to sites.json with:
    """
    {
      "site": {
        "name": "New site",
        "subdomain": "new-site"
      }
    }
    """
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries

  Scenario: Creating new site as a Designer
    Given I have a "designer" API token
    When I do an API POST to sites.json with:
    """
    {
      "site": {
        "name": "New site",
        "subdomain": "new-site"
      }
    }
    """
    Then an access denied error should occur

  Scenario: Creating new site as an Author
    Given I have an "author" API token
    When I do an API POST to sites.json with:
    """
    {
      "site": {
        "name": "New site",
        "subdomain": "new-site"
      }
    }
    """
    Then an access denied error should occur

  # update site

  Scenario: Updating site as an Admin
    Given I have an "admin" API token
    When I do an API PUT to sites/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "site": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating my site as a Designer
    Given I have a "designer" API token
    When I do an API PUT to sites/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "site": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating other site as a Designer
    Given I have a "designer" API token
    When I do an API PUT to sites/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "site": {
        "name": "Brand new updated name"
      }
    }
    """
    Then an access denied error should occur

  Scenario: Updating my site as an Author
    Given I have a "author" API token
    When I do an API PUT to sites/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "site": {
        "name": "Brand new updated name"
      }
    }
    """
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "id" should be "4f832c2cb0d86d3f42fffffe"
    And the JSON response at "name" should be "Brand new updated name"

  Scenario: Updating other site as an Author
    Given I have a "author" API token
    When I do an API PUT to sites/4f832c2cb0d86d3f42ffffff.json with:
    """
    {
      "site": {
        "name": "Brand new updated name"
      }
    }
    """
    Then an access denied error should occur

  # destroy site

  Scenario: Destroying site as an Admin
    Given I have an "admin" API token
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to sites/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to sites.json
    Then the JSON response should be an array
    And the JSON response should have 1 entries

  Scenario: Destroying my site as a Designer
    Given I have a "designer" API token
    When I do an API DELETE to sites/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to sites/4f832c2cb0d86d3f42fffffe.json
    Then it should not exist

  Scenario: Deleting other site as a Designer
    Given I have a "designer" API token
    When I do an API DELETE to sites/4f832c2cb0d86d3f42ffffff.json
    Then an access denied error should occur

  Scenario: Deleting my site as an Author
    Given I have a "author" API token
    When I do an API DELETE to sites/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur

  Scenario: Deleting other site as an Author
    Given I have a "author" API token
    When I do an API DELETE to sites/4f832c2cb0d86d3f42ffffff.json
    Then an access denied error should occur
