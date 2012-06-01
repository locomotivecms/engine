Feature: Content Types
  In order to manage content types programmatically
  As an API user
  I will be able to create and update content types

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token

  Scenario: Creating Content Type with order_by_attribute (should ignore order_by)
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "order_by": "1234",
        "order_by_attribute": "name",
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
    And the JSON response at "0/order_by_attribute" should be "name"


  Scenario: Creating Content Type with special order_by_attribute
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "Employees",
        "slug": "employees",
        "order_by_attribute": "updated_at",
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
    And the JSON response at "0/order_by_attribute" should be "updated_at"
