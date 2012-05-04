Feature: Editable Elements
  In order to manage editable elements programmatically
  As an API user
  I will be able to create and update editable elements

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And a page named "hello-world" with id "4f832c2cb0d86d3f42fffffe" and template:
    """
    {% editable_long_text welcome %}
    Welcome to my site!
    {% endeditable_long_text %}

    {% block main %}
    {% editable_short_text subtitle %}
    Article #1
    {% endeditable_short_text %}
    {% endblock %}
    """

  Scenario: Update editable element content
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then I keep the JSON response at "editable_elements/0/id" as "LONG_TEXT_ID"
    And I keep the JSON response at "editable_elements/1/id" as "SHORT_TEXT_ID"
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "editable_elements": [
          {
            "id": %{LONG_TEXT_ID},
            "content": "My new welcome content!!!"
          },
          {
            "id": %{SHORT_TEXT_ID},
            "content": "My new main content!!!"
          }
        ]
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "editable_elements" should have 2 entries
    And the JSON response at "editable_elements/0/content" should be "My new welcome content!!!"
    And the JSON response at "editable_elements/1/content" should be "My new main content!!!"

  Scenario: Create new editable element on existing page
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "raw_template": "{% editable_short_text my_short_text %}{% endeditable_short_text %} {% block main %}{% editable_long_text my_long_text %}{% endeditable_long_text %}{% endblock %}",
        "editable_elements": [
          {
            "slug": "my_short_text",
            "block": null,
            "content": "The new short text content",
            "type": "EditableShortText"
          },
          {
            "slug": "my_long_text",
            "block": "main",
            "content": "<p>The new long text content</p>",
            "type": "EditableLongText"
          }
        ]
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "editable_elements" should have 2 entries
    And the JSON response should have the following:
      | editable_elements/0/slug    | "my_short_text"                       |
      | editable_elements/0/block   | null                                  |
      | editable_elements/0/content | "The new short text content"          |
      | editable_elements/1/slug    | "my_long_text"                        |
      | editable_elements/1/block   | "main"                                |
      | editable_elements/1/content | "<p>The new long text content</p>"    |

  Scenario: Create new editable element on new page
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "New Page",
        "parent_fullpath": "index",
        "raw_template": "{% editable_short_text my_short_text %}{% endeditable_short_text %} {% block main %}{% editable_long_text my_long_text %}{% endeditable_long_text %}{% endblock %}",
        "editable_elements": [
          {
            "slug": "my_short_text",
            "block": null,
            "content": "The new short text content",
            "type": "EditableShortText"
          },
          {
            "slug": "my_long_text",
            "block": "main",
            "content": "<p>The new long text content</p>",
            "type": "EditableLongText"
          }
        ]
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response at "3/editable_elements" should have 2 entries
    And the JSON response should have the following:
      | 3/editable_elements/0/slug      | "my_short_text"                       |
      | 3/editable_elements/0/block     | null                                  |
      | 3/editable_elements/0/content   | "The new short text content"          |
      | 3/editable_elements/1/slug      | "my_long_text"                        |
      | 3/editable_elements/1/block     | "main"                                |
      | 3/editable_elements/1/content   | "<p>The new long text content</p>"    |
