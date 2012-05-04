Feature: Entries Custom Fieldws
  In order to manage custom fields programmatically
  As an API user
  I will be able to create and update editable elements

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And I have a custom model named "Projects" with id "4f832c2cb0d86d3f42fffffe" and
      | label       | type      | required        |
      | Name        | string    | true            |
      | Description | text      | false           |

  Scenario: Update custom field
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then I keep the JSON response at "entries_custom_fields/0/id" as "NAME_ID"
    And I keep the JSON response at "entries_custom_fields/1/id" as "DESC_ID"
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "entries_custom_fields": [
          {
            "id": %{NAME_ID},
            "label": "Super cool name"
          },
          {
            "id": %{DESC_ID},
            "label": "Super cool description"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "entries_custom_fields" should have 2 entries
    And the JSON response at "entries_custom_fields/0/label" should be "Super cool name"
    And the JSON response at "entries_custom_fields/1/label" should be "Super cool description"

  Scenario: Create new custom fields on existing page
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "entries_custom_fields": [
          {
            "label": "Title",
            "type": "string"
          },
          {
            "label": "Content",
            "type": "text"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "entries_custom_fields" should have 4 entries
    And the JSON response should have the following:
      | entries_custom_fields/2/label   | "Title"   |
      | entries_custom_fields/2/type    | "string"  |
      | entries_custom_fields/3/label   | "Content" |
      | entries_custom_fields/3/type    | "text"    |

  Scenario: Create new custom field on new content type
    When I do an API POST to content_types.json with:
    """
    {
      "content_type": {
        "name": "My New Content Type",
        "entries_custom_fields": [
          {
            "label": "Title",
            "type": "string"
          },
          {
            "label": "Content",
            "type": "text"
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types.json
    Then the JSON response at "1/entries_custom_fields" should have 2 entries
    And the JSON response should have the following:
      | 1/entries_custom_fields/0/label | "Title"   |
      | 1/entries_custom_fields/0/type  | "string"  |
      | 1/entries_custom_fields/1/label | "Content" |
      | 1/entries_custom_fields/1/type  | "text"    |
