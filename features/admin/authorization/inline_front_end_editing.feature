@javascript
Feature: Inline frontend editing
  In order to ensure site content is not tampered with
  As an admin, designer or author
  I will be restricted based on my role

  Background:
    Given I have the site: "test site" set up
    And I have a designer and an author
    Given a page named "about" with the template:
    """
    <html>
      <head>{% inline_editor %}</head>
      <body>Page Content</body>
    </html>
    """

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I view the rendered page at "/about"
    Then I should not see "edit"
    When I view the rendered page at "/about/edit"
    Then I should not see "Page Content"
    And I should see "Log in"

  Scenario: Inline editing as an Admin
    Given I am an authenticated "admin"
    When I view the rendered page at "/about"
    Then I should see "admin"
    And I should see "edit"
    When I view the rendered page at "/about/edit"
    Then I should see "Page Content"

  Scenario: Inline editing as a Designer
    Given I am an authenticated "designer"
    When I view the rendered page at "/about"
    Then I should see "admin"
    And I should see "edit"
    When I view the rendered page at "/about/edit"
    Then I should see "Page Content"

  Scenario: Inline editing as an Author
    Given I am an authenticated "author"
    When I view the rendered page at "/about"
    Then I should see "admin"
    And I should see "edit"
    When I view the rendered page at "/about/edit"
    Then I should see "Page Content"
