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
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "editable_elements": [
          {
            "id": %{LONG_TEXT_ID},
            "content": "My new welcome content!!!"
          }
        ]
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response at "editable_elements/0/content" should be "My new welcome content!!!"
