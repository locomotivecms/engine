Feature: Create and manage has many relationships
  In order to work with two associated models together
  As an administrator
  I want to set up and manage a has many relationship

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Clients" with
    | label       | type      | required    | target   |
    | Name        | string    | true        |          |
    | Description | string    | false       |          |
  And I have a custom model named "Projects" with
    | label       | type        | required    | target  |
    | Name        | string      | true        |         |
    | Description | text        | false       |         |
    | Client      | belongs_to  | false       | Clients |
  And I set up a has_many relationship between "Clients" and "Projects"
  And I have entries for "Clients" with
    | name              | description                |
    | Alpha, Inc        | Description for Alpha, Inc |
    | Beta, Inc         | Description for Beta, Inc  |
    | Gamma, Inc        | Description for Gamma, Inc |
  And I have entries for "Projects" with
    | name              | description                    |
    | Fun project       | Description for the fun one    |
    | Boring project    | Description for the boring one |

  And I am an authenticated user

@javascript
Scenario: I view a client without any projects
  When I go to the list of "Clients"
  And I choose "Alpha, Inc" in the list
  Then I should see "The list is empty" within the list of entries

@javascript
Scenario: I add a project to a client
  When I go to the list of "Projects"
  And I choose "Fun project" in the list
  And I select2 "Alpha, Inc" from "content_entry_client_id"
  And I press "Save"
  Then I should see "Entry was successfully updated."
  When I go to the list of "Clients"
  And I choose "Alpha, Inc" in the list
  Then I should see "Fun project" within the list of entries

@javascript
Scenario: I add a project to a client from the client page
  When I go to the list of "Clients"
  And I choose "Beta, Inc" in the list
  And I follow "+ Add a new entry"
  Then I should see "Projects — new entry"
  When I press "Create" within the dialog popup
  Then I should see "Entry was not created."
  When I fill in "Name" with "Project X" within the dialog popup
  And I fill in "Description" with "Lorem ipsum" within the dialog popup
  And I press "Create" within the dialog popup
  Then I should see "Entry was successfully created."
  And I should see "Project X" within the list of entries
  And "p.empty" should not be visible within the list of entries

Scenario: with_scope with label value
  Given the "client" "Alpha, Inc" has "Fun project" as one of its "projects"
  And a page named "alpha-projects" with the template:
    """
    <hr>
    {% with_scope client: "Alpha, Inc" %}
    {% for project in contents.projects %}- {{ project.name }}<br>{% endfor %}
    {% endwith_scope %}
    <hr>
    """
  When I view the rendered page at "/alpha-projects"
  Then the rendered output should look like:
    """
    <hr>

    - Fun project<br>

    <hr>
    """
