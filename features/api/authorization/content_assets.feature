Feature: Content Assets
  In order to ensure content assets are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And I have the following content assets:
      | id                          | file      |
      | 4f832c2cb0d86d3f42fffffe    | 5k.png    |
      | 4f832c2cb0d86d3f42ffffff    | 5k_2.png  |
    And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I do an API GET to content_assets.json
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  # listing content assets

  Scenario: Accessing content assets as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing content assets as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  Scenario: Accessing content assets as an Author
    Given I have an "author" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries

  # showing content asset

  Scenario: Accessing content asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "5k.png"

  Scenario: Accessing content asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "5k.png"

  Scenario: Accessing content asset as an Author
    Given I have an "author" API token
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "5k.png"

  # create content asset

  Scenario: Creating new content asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do a multipart API POST to content_assets.json with base key "content_asset" and:
      | source  | assets/application.js     |
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON at "2/filename" should be "application.js"

  Scenario: Creating new content asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do a multipart API POST to content_assets.json with base key "content_asset" and:
      | source  | assets/application.js     |
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON at "2/filename" should be "application.js"

  Scenario: Creating new content asset as an Author
    Given I have an "author" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do a multipart API POST to content_assets.json with base key "content_asset" and:
      | source  | assets/application.js     |
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON at "2/filename" should be "application.js"

  # update content asset

  Scenario: Updating content asset as an Admin
    Given I have an "admin" API token
    When I do a multipart API PUT to content_assets/4f832c2cb0d86d3f42fffffe.json with base key "content_asset" and:
      | source  | assets/main.css   |
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "main.css"

  Scenario: Updating content asset as a Designer
    Given I have a "designer" API token
    When I do a multipart API PUT to content_assets/4f832c2cb0d86d3f42fffffe.json with base key "content_asset" and:
      | source  | assets/main.css   |
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "main.css"

  Scenario: Updating content asset as an Author
    Given I have a "author" API token
    When I do a multipart API PUT to content_assets/4f832c2cb0d86d3f42fffffe.json with base key "content_asset" and:
      | source  | assets/main.css   |
    When I do an API GET request to content_assets/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "filename" should be "main.css"

  # destroy content asset

  Scenario: Destroying content asset as an Admin
    Given I have an "admin" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_assets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Destroying content asset as a Designer
    Given I have a "designer" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_assets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry

  Scenario: Deleting content asset as an Author
    Given I have a "author" API token
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    When I do an API DELETE to content_assets/4f832c2cb0d86d3f42fffffe.json
    When I do an API GET request to content_assets.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
