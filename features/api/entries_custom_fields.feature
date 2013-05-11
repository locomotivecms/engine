Feature: Entries Custom Field
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


  Scenario: Return the minimal set of attributes for each kind of field
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON at "entries_custom_fields/0" should have 9 keys
    Then the JSON at "entries_custom_fields/1" should have 10 keys

  Scenario: Update custom field
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "entries_custom_fields": [
          {
            "name": "name",
            "label": "Super cool name"
          },
          {
            "name": "description",
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

  Scenario: Delete a custom field
    When I do an API PUT to content_types/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "content_type": {
        "entries_custom_fields": [
          {
            "name": "name",
            "label": "Super cool name"
          },
          {
            "name": "description",
            "_destroy": true
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "entries_custom_fields" should have 1 entry
    And the JSON response at "entries_custom_fields/0/label" should be "Super cool name"

  Scenario: Create new custom fields for existing content type
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
          },
          {
            "label": "Category",
            "type": "select",
            "select_options": [
              {
                "position": 1,
                "name": {
                  "en": "category1 (EN)",
                  "fr": "category1 (FR)"
                }
              },
              {
                "position": 2,
                "name": {
                  "en": "category2 (EN)",
                  "fr": "category2 (FR)"
                }
              }
            ]
          }
        ]
      }
    }
    """
    When I do an API GET request to content_types/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "entries_custom_fields" should have 5 entries
    And the JSON response should have the following:
      | entries_custom_fields/2/label                         | "Title"           |
      | entries_custom_fields/2/type                          | "string"          |
      | entries_custom_fields/3/label                         | "Content"         |
      | entries_custom_fields/3/type                          | "text"            |
      | entries_custom_fields/4/label                         | "Category"        |
      | entries_custom_fields/4/type                          | "select"          |
      | entries_custom_fields/4/select_options/0/name         | "category1 (EN)"  |
      | entries_custom_fields/4/select_options/1/name         | "category2 (EN)"  |
      | entries_custom_fields/4/raw_select_options/0/name/fr  | "category1 (FR)"  |

  Scenario: Create new custom field on new content type
    When I do an API GET request to content_types.json
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
          },
          {
            "label": "Project",
            "type": "belongs_to",
            "class_name": "projects"
          }
        ]
      }
    }
    """
    Then the JSON response at "entries_custom_fields" should have 3 entries
    And the JSON response should have the following:
      | entries_custom_fields/0/label       | "Title"                                             |
      | entries_custom_fields/0/type        | "string"                                            |
      | entries_custom_fields/1/label       | "Content"                                           |
      | entries_custom_fields/1/type        | "text"                                              |
      | entries_custom_fields/2/label       | "Project"                                           |
      | entries_custom_fields/2/type        | "belongs_to"                                        |
      | entries_custom_fields/2/class_name  | "Locomotive::ContentEntry4f832c2cb0d86d3f42fffffe"  |
      | entries_custom_fields/2/class_slug  | "projects"                                          |
