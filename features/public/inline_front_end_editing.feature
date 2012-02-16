@wip
@javascript
Feature: Engine
  As an author
  In order to easily be able to modify the contents of my website
  I want to be able to edit the sites content on the front end

  Background:
    Given I have the site: "test site" set up
    And I am an authenticated "author"

  Scenario: Editing a short text field
    Given a page named "about" with the template:
    """
    <html>
      <head>{% inline_editor %}</head>
      <body>{% editable_short_text 'owner' %}Tom{% endeditable_short_text %} owns this website</body>
    </html>
    """
    When I view the rendered page at "/about"
    Then I should see "edit"
    When I follow "edit"
    And I type the content "Mario" into the first editable field
    And I follow "save"
    And I view the rendered page at "/about"
    Then I should see "Mario owns this website"
