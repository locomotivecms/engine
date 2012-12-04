Feature: Content Types
  In order to manage content types programmatically
  As an API user
  I will be able to create and update content types

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token

  Scenario: Creating Content Type with order_by
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "order_by": "name",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Position",
            "name": "position",
            "type": "string"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I keep the JSON response at "0/entries_custom_fields/0/id" as "ORDER_BY_ATTRIBUTE_ID"
    Then the JSON response at "0/order_by" should be %{ORDER_BY_ATTRIBUTE_ID}
    And the JSON response at "0/order_by_field_name" should be "name"

  Scenario: Creating Content Type with special order_by
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "order_by": "updated_at",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Position",
            "name": "position",
            "type": "string"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    And the JSON response at "0/order_by" should be "updated_at"
    And the JSON response at "0/order_by_field_name" should be "updated_at"

  Scenario: Creating Content Type with group_by_field_name
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "group_by_field_name": "category",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          },
          {
            "label": "Category",
            "name": "category",
            "type": "select"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    When I keep the JSON response at "0/entries_custom_fields/1/id" as "GROUP_BY_FIELD_ID"
    Then the JSON response at "0/group_by_field_id" should be %{GROUP_BY_FIELD_ID}
    And the JSON response at "0/group_by_field_name" should be "category"

  Scenario: Creating Content Type with public_submission_account_emails
    Given I have accounts:
      | email         | id                        |
      | user1@a.com   | 4f832c2cb0d86d3f42fffffc  |
      | user2@a.com   | 4f832c2cb0d86d3f42fffffd  |
      | user3@a.com   | 4f832c2cb0d86d3f42fffffe  |
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          }
        ],
        "public_submission_enabled": true,
        "public_submission_account_emails": [ "user1@a.com", "user2@a.com" ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    And the JSON response at "0/public_submission_account_emails/0" should be "user1@a.com"
    And the JSON response at "0/public_submission_account_emails/1" should be "user2@a.com"

  Scenario: Creating Content Type with invalid public_submission_account_emails
    Given I have accounts:
      | email         | id                        |
      | user1@a.com   | 4f832c2cb0d86d3f42fffffc  |
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "entries_custom_fields": [
          {
            "label": "Name",
            "name": "name",
            "type": "string"
          }
        ],
        "public_submission_enabled": true,
        "public_submission_account_emails": [ "user1@a.com", "user2@a.com" ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response should be an array
    And the JSON response should have 1 entry
    And the JSON response at "0/public_submission_account_emails" should be an array
    And the JSON response at "0/public_submission_account_emails" should have 1 entry
    And the JSON response at "0/public_submission_account_emails/0" should be "user1@a.com"
