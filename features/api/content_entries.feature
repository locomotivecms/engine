Feature: Content Entries
  In order to manage content entries programmatically
  As an API user
  I will be able to create and update content entries

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And I have a custom model named "Clients" with
      | label   | type      | required  |
      | Name    | string    | true      |
    And I have a custom model named "Projects" with
      | label   | type          | required  | target    |
      | Name    | string        | true      |           |
      | Desc    | text          | false     |           |
      | Type    | select        | false     |           |
      | Started | boolean       | false     |           |
      | Due     | date          | false     |           |
      | Logo    | file          | false     |           |
      | Client  | belongs_to    | false     | Clients   |
    And I have "code, design" as "Type" values of the "Projects" model
    And I have a custom model named "Workers" with
      | label       | type          | required  |
      | Name        | string        | true      |
    And I have a custom model named "Tasks" with
      | label     | type        | required  | target    |
      | Name      | string      | true      |           |
      | Project   | belongs_to  | false     | Projects  |
    And I set up a has_many relationship between "Clients" and "Projects"
    And I set up a has_many relationship between "Projects" and "Tasks"
    And I set up a many_to_many relationship between "Projects" and "Workers"
    And I have entries for "Clients" with
      | id                          | name  |
      | 4f832c2cb0d86d3f42fffff8    | c1    |
      | 4f832c2cb0d86d3f42fffff9    | c2    |
    And I have entries for "Workers" with
      | id                          | name  |
      | 4f832c2cb0d86d3f42fffffa    | w1    |
      | 4f832c2cb0d86d3f42fffffb    | w2    |
      | 4f832c2cb0d86d3f42fffffc    | w3    |
    And I have entries for "Tasks" with
      | id                          | name  |
      | 4f832c2cb0d86d3f42fffffd    | t1    |
      | 4f832c2cb0d86d3f42fffffe    | t2    |
      | 4f832c2cb0d86d3f42ffffff    | t3    |
    And I have entries for "Projects" with
      | id                          | name  | desc  | type    | started   | due         | logo        |
      | 4f832c2cb0d86d3f42fffff0    | p1    | first | code    | false     | 2012-07-01  | logo1.jpg   |
      | 4f832c2cb0d86d3f42fffff1    | p2    | 2nd   | design  | true      | 2012-11-30  | logo1.jpg   |

  # create content entry

  Scenario: Creating new project
    Given the JSON request at "content_entry/logo" is a file
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "desc": "The third",
        "type": "code",
        "started": false,
        "due": "2012/06/01",
        "logo": "images/logo2.jpg",
        "workers": ["w1", "w3"],
        "client": "c1"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/name              | "Project 3"                   |
      | 2/desc              | "The third"                   |
      | 2/type              | "code"                        |
      | 2/started           | false                         |
      | 2/due               | "06/01/2012"                  |
      | 2/workers/0         | "w1"                          |
      | 2/workers/1         | "w3"                          |
      | 2/client            | "c1"                          |
    And the JSON at "2/logo" should match /logo2.jpg$/
    And the response content type should match /application\/json/

  Scenario: Updating existing project
    Given the JSON request at "content_entry/logo" is a file
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffff0.json with:
    """
    {
      "content_entry": {
        "name": "Awesome title",
        "desc": "Awesome Desc",
        "type": "design",
        "started": true,
        "formatted_due": "2012/06/12",
        "logo": "images/logo2.jpg",
        "workers": ["w3", "w2"],
        "client": "c2"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 2 entries
    And the JSON should have the following:
      | 0/name              | "Awesome title"               |
      | 0/desc              | "Awesome Desc"                |
      | 0/type              | "design"                      |
      | 0/started           | true                          |
      | 0/due               | "06/12/2012"                  |
      | 0/workers/0         | "w3"                          |
      | 0/workers/1         | "w2"                          |
      | 0/client            | "c2"                          |
    And the JSON at "0/logo" should match /logo2.jpg$/
    And the response content type should match /application\/json/

  # FIXME: (Did) What is the use case to modify the timestamps of a content entry
  @wip
  Scenario: Creating new project with timestamps
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "formatted_created_at": "2000-02-01T17:30:00-04:00",
        "formatted_updated_at": "2001-03-02T18:40:10-03:00"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON at "2/name" should be "Project 3"
    And the JSON at "2/created_at" should be the time "2000-02-01T17:30:00-04:00"
    And the JSON at "2/updated_at" should be the time "2001-03-02T18:40:10-03:00"

  Scenario: Updating project SEO data
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffff0.json with:
    """
    {
      "content_entry": {
        "seo_title": "New super-cool SEO title",
        "meta_keywords": "key1,key2",
        "meta_description": "My SEO description"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffff0.json
    Then the JSON should have the following:
      | seo_title           | "New super-cool SEO title"    |
      | meta_keywords       | "key1,key2"                   |
      | meta_description    | "My SEO description"          |

  Scenario: Updating project select field with an unknown value
    When I do an API PUT to content_types/projects/entries/4f832c2cb0d86d3f42fffff0.json with:
    """
    {
      "content_entry": {
        "type": "unknown"
      }
    }
    """
    When I do an API GET request to content_types/projects/entries/4f832c2cb0d86d3f42fffff0.json
    Then the JSON response should not have "type"

  Scenario: View a single project
    When I do an API GET request to content_types/projects/entries/p1.json
    Then the JSON should have the following:
      | name | "p1"          |
      | desc | "first"       |

