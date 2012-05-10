Feature: Content Entries
  In order to manage content entries programmatically
  As an API user
  I will be able to create and update content entries

  Background:
    Given I have the site: "test site" set up
    And I have an "admin" API token
    And I have a custom model named "Projects" with
      | label   | type      | required  |
      | Name    | string    | true      |
      | Desc    | text      | false     |
      | Type    | select    | false     |
      | Started | boolean   | false     |
      | Due     | date      | false     |
      | Logo    | file      | false     |
  And I have "code, design" as "Type" values of the "Projects" model
    And I have a custom model named "Workers" with
      | label       | type          | required  |
      | Name        | string        | true      |
    And I have a custom model named "Tasks" with
      | label     | type        | required  | target    |
      | Name      | string      | true      |           |
      | Project   | belongs_to  | false     | Projects  |
    And I set up a has_many relationship between "Projects" and "Tasks"
    And I set up a many_to_many relationship between "Projects" and "Workers"
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
      | name  | desc  | type    | started   | due         | logo        |
      | p1    | first | code    | false     | 2012-07-01  | logo1.jpg   |
      | p2    | 2nd   | design  | true      | 2012-11-30  | logo1.jpg   |

  # create content entry

  Scenario: Creating new project
    When I do an API POST to content_types/projects/entries.json with:
    """
    {
      "content_entry": {
        "name": "Project 3",
        "desc": "The third",
        "type": "code",
        "started": false,
        "formatted_due": "06/01/2012",
        "tasks": [ "t1", "t3" ],
        "workers": [ "w1", "w3" ]
      }
    }
    """
    When I do an API GET request to content_types/projects/entries.json
    Then the JSON response should be an array
    And the JSON response should have 3 entries
    And the JSON should have the following:
      | 2/name              | "Project 3"   |
      | 2/desc              | "The third"   |
      | 2/type              | "code"        |
      | 2/started           | false         |
      | 2/formatted_due     | "06/01/2012"  |
      | 2/tasks/0/name      | "t1"          |
      | 2/tasks/1/name      | "t3"          |
      | 2/workers/0/name    | "w1"          |
      | 2/workers/1/name    | "w3"          |
