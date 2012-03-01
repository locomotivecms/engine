Feature: TableRow liquid tags
  As a designer
  I want to be able to use the tablerow liquid tag with locomotive contents

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label         | type      | required  |
    | Name          | string    | true      |
  And I have entries for "Projects" with
    | name        | _position |
    | Project 1   | 1         |
    | Project 2   | 2         |
    | Project 3   | 3         |

Scenario: Use the tablerow tag
  Given a page named "project-table" with the template:
    """
    <h1>Projects</h1>
    <table>
    {% tablerow project in contents.projects cols: 2 %}
    {{ project.name }}
    {% endtablerow %}
    </table>
    """
  When I view the rendered page at "/project-table"
  Then the rendered output should look like:
    """
    <h1>Projects</h1>
    <table>
    <tr class="row1">
    <td class="col1">
    Project 1
    </td><td class="col2">
    Project 2
    </td></tr>
    <tr class="row2"><td class="col1">
    Project 3
    </td></tr>

    </table>
    """
