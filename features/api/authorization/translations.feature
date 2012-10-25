Feature: Translations
  In order to ensure translations are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up with id: "4f832c2cb0d86d3f42fffffb"
    And the site "Locomotive test website" has locales "en, es, fr"
    And a translation with key "the_cake_is_a_lie" and id "4f832c2cb0d86d3f42fffffe" with values:
      | en | The cake is a lie         |
      | es | La tarta es mentira       |

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to translations.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  Scenario: Accessing translations as an Admin
    Given I have an "admin" API token
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing translations as a Designer
    Given I have a "designer" API token
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing translations as an Author
    Given I have an "author" API token
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Accessing translations as an Admin
    Given I have an "admin" API token
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "values" should be:
      """
        {
          "en": "The cake is a lie",
          "es": "La tarta es mentira"
        }
      """

  Scenario: Accessing translation as a Designer
    Given I have a "designer" API token
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "values" should be:
      """
        {
          "en": "The cake is a lie",
          "es": "La tarta es mentira"
        }
      """

  Scenario: Accessing translation as an Author
    Given I have an "author" API token
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "values" should be:
      """
        {
          "en": "The cake is a lie",
          "es": "La tarta es mentira"
        }
      """

  Scenario: Creating new translation as an Admin
    Given I have an "admin" API token
    When I do an API POST to translations.json with:
    """
      {
        "translation": {
          "key": "hello_world",
          "values": {
            "en": "Hello, World",
            "es": "Hola, Mundo",
            "fr": "Bonjour, le Monde"
          }
        }
      }
    """
    And I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON response at "1" should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "hello_world",
          "values": {
            "en": "Hello, World",
            "es": "Hola, Mundo",
            "fr": "Bonjour, le Monde"
          }
        }
      """

  Scenario: Creating new translation as a Designer
    Given I have a "designer" API token
    When I do an API POST to translations.json with:
    """
    {
      "translation": {
        "key": "hello_world",
        "values": {
          "en": "Hello, World",
          "es": "Hola, Mundo",
          "fr": "Bonjour, le Monde"
        }
      }
    }
    """
    And I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON response at "1" should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "hello_world",
          "values": {
            "en": "Hello, World",
            "es": "Hola, Mundo",
            "fr": "Bonjour, le Monde"
          }
        }
      """

  Scenario: Creating new translation as an Author
    Given I have an "author" API token
    When I do an API POST to translations.json with:
    """
    {
      "translation": {
        "key": "hello_world",
        "values": {
          "en": "Hello, World",
          "es": "Hola, Mundo",
          "fr": "Bonjour, le Monde"
        }
      }
    }
    """
    And I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON response at "1" should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "hello_world",
          "values": {
            "en": "Hello, World",
            "es": "Hola, Mundo",
            "fr": "Bonjour, le Monde"
          }
        }
      """
  # update translation

  Scenario: Updating translation as an Admin
    Given I have an "admin" API token
    When I do an API PUT to translations/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "translation": {
        "key": "the_cake_is_true",
        "values": {
          "en": "The cake is true"
        }
      }
    }
    """
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "the_cake_is_true",
          "values": {
            "en": "The cake is true"
          }
        }
      """

  Scenario: Updating translation as a Designer
    Given I have a "designer" API token
    When I do an API PUT to translations/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "translation": {
        "key": "the_cake_is_true",
        "values": {
          "en": "The cake is true"
        }
      }
    }
    """
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "the_cake_is_true",
          "values": {
            "en": "The cake is true"
          }
        }
      """
      
  Scenario: Updating translation as an Author
    Given I have a "author" API token
    When I do an API PUT to translations/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "translation": {
        "key": "the_cake_is_true",
        "values": {
          "en": "The cake is true"
        }
      }
    }
    """
    When I do an API GET request to translations/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should be:
      """
        {
          "site_id": "4f832c2cb0d86d3f42fffffb",
          "key": "the_cake_is_true",
          "values": {
            "en": "The cake is true"
          }
        }
      """
      
  # destroy translation

  Scenario: Destroying translation as an Admin
    Given I have an "admin" API token
    When I do an API DELETE to translations/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Destroying translation as a Designer
    Given I have a "designer" API token
    When I do an API DELETE to translations/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries

  Scenario: Deleting translation as an Author
    Given I have a "author" API token
    When I do an API DELETE to translations/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to translations.json
    Then the JSON response should be an array
    And the JSON response should have 0 entries
