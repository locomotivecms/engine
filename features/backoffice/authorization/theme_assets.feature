Feature: Theme Assets
  In order to ensure theme assets are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

Background:
  Given I have the site: "test site" set up
  And I have a designer and an author
  And I have an image theme asset named "dog.png"

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to theme assets
    Then I should see "Log in"

  @javascript
  Scenario: Accessing theme assets as an Admin
    Given I am an authenticated "admin"
    When I go to theme assets
    Then I should see "new snippet"
    And I should see "new file"
    And I should see "Snippets"
    And I should see "Style and javascript"
    And I should see "Images"
    And I should see "dog.png"
    And I should see a delete link

  @javascript
  Scenario: Accessing theme assets as a Designer
    Given I am an authenticated "designer"
    When I go to theme assets
    Then I should see "new snippet"
    And I should see "new file"
    And I should see "Snippets"
    And I should see "Style and javascript"
    And I should see "Images"
    And I should see "dog.png"
    And I should see a delete link

  @javascript
  Scenario: Accessing theme assets as an Author
    Given I am an authenticated "author"
    When I go to theme assets
    Then I should not see "new snippet"
    And I should not see "new file"
    And I should not see "Snippets"
    And I should not see "Style and javascript"
    And I should see "Images"
    And I should see "dog.png"
    And I should not see a delete link
