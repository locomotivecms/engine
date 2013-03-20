Feature: Theme Assets
  In order to ensure theme assets are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And a javascript asset named "my_javascript.js" with id "4f832c2cb0d86d3f42fffffe"
    And a stylesheet asset named "my_stylesheet.css" with id "4f832c2cb0d86d3f42ffffff"

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to theme_assets.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing theme assets

  Scenario: Accessing theme assets as an Admin
    Given I have an "admin" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing theme assets as a Designer
    Given I have a "designer" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing theme assets as an Author
    Given I have an "author" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  # showing theme asset

  Scenario: Accessing theme asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "local_path" should be "my_javascript.js"

  Scenario: Accessing theme asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "local_path" should be "my_javascript.js"

  Scenario: Accessing theme asset as an Author
    Given I have an "author" API token
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "local_path" should be "my_javascript.js"

  # create theme asset

  Scenario: Creating new theme asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to theme_assets.json with:
    """
    {
      "theme_asset": {
        "plain_text_name": "new-javascript.js",
        "plain_text": "function doNothing() {}",
        "plain_text_type": "javascript",
        "performing_plain_text": "true"
      }
    }
    """
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/local_path    | "new-javascript.js"           |
      | 2/content_type  | "javascript"                  |

  Scenario: Creating new theme asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API POST to theme_assets.json with:
    """
    {
      "theme_asset": {
        "plain_text_name": "new-javascript.js",
        "plain_text": "function doNothing() {}",
        "plain_text_type": "javascript",
        "performing_plain_text": "true"
      }
    }
    """
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/local_path    | "new-javascript.js"           |
      | 2/content_type  | "javascript"                  |

  Scenario: Creating new theme asset as an Author
    Given I have an "author" API token
    When I do an API POST to theme_assets.json with:
    """
    {
      "theme_asset": {
        "plain_text_name": "new-javascript.js",
        "plain_text": "function doNothing() {}",
        "plain_text_type": "javascript",
        "performing_plain_text": "true"
      }
    }
    """
    Then an access denied error should occur

  # update theme asset

  Scenario: Updating theme asset as an Admin
    Given I have an "admin" API token
    When I do an API PUT to theme_assets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "theme_asset": {
        "folder": "changed"
      }
    }
    """
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should have the following:
      | local_path  | "changed/my_javascript.js"     |

  Scenario: Updating theme asset as a Designer
    Given I have a "designer" API token
    When I do an API PUT to theme_assets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "theme_asset": {
        "folder": "changed"
      }
    }
    """
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should have the following:
      | local_path  | "changed/my_javascript.js"     |

  Scenario: Updating theme asset as an Author
    Given I have a "author" API token
    When I do an API PUT to theme_assets/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "theme_asset": {
        "folder": "changed"
      }
    }
    """
    When I do an API GET request to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should have the following:
      | local_path  | "changed/my_javascript.js"     |

  # destroy theme asset

  Scenario: Destroying theme asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to theme_assets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entries

  Scenario: Destroying theme asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to theme_assets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to theme_assets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entries

  Scenario: Deleting theme asset as an Author
    Given I have a "author" API token
    When I do an API DELETE to theme_assets/4f832c2cb0d86d3f42fffffe.json
    Then an access denied error should occur
