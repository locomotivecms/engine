Feature: Pages
  In order to access the Page resources
  As an admin
  I will perform the basic RESTFUL actions on them

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And a page named "hello world" with the template:
    """
    Hello world :-)
    """
    And a page named "goodbye-world" with the template:
    """
    Goodbye world :-(
    """
    And I have a custom model named "Projects" with id "4f832c2cb0d86d3f42fffffe" and
      | label       | type      | required        |
      | Name        | string    | true            |
      | Description | text      | false           |

  Scenario: Protect the pages resources if not authenticated
    Given I do not have an API token
    When I visit "/locomotive/api/pages.json"
    Then the JSON response at "error" should be "You need to sign in or sign up before continuing."

  Scenario: Accessing pages
    When I visit "/locomotive/api/pages.json"
    Then the JSON should have the following:
      | 0/fullpath | "index"          |
      | 1/fullpath | "hello-world"    |
      | 2/fullpath | "404"            |
      | 3/fullpath | "goodbye-world"  |

  Scenario: Creating templatized page
    # "target_entry_name": "projects",
    When I do an API POST to pages.json with:
    """
    {
      "page": {
        "title": "My Templatized Page",
        "templatized": "true",
        "templatized_from_parent": "false",
        "target_klass_slug": "projects",
        "parent_fullpath": "index"
      }
    }
    """
    When I do an API GET request to pages.json
    Then the JSON response should be an array
    And the JSON response should have 5 entries
    And the JSON response at "4/title" should be "My Templatized Page"
    And the JSON response at "4/target_klass_slug" should be "projects"

  Scenario: Saving page SEO data
    Given a page named "yet another page" with id "4f832c2cb0d86d3f42fffffe"
    And I have an "admin" API token
    When I do an API PUT to pages/4f832c2cb0d86d3f42fffffe.json with:
    """
    {
      "page": {
        "seo_title": "Awesome SEO title",
        "meta_keywords": "keywords,more_keywords,",
        "meta_description": "It is awesome"
      }
    }
    """
    When I do an API GET request to pages/4f832c2cb0d86d3f42fffffe.json
    Then the JSON response should have the following:
      | seo_title           | "Awesome SEO title"       |
      | meta_keywords       | "keywords,more_keywords," |
      | meta_description    | "It is awesome"           |
