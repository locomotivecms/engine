Feature: Site Settings
  In order to ensure site settings are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

Background:
  Given I have the site: "test site" set up
  And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to site settings
    Then I should see "Log in"

  @javascript
  Scenario: Accessing site settings as an Admin
    Given I am an authenticated "admin"
    When I go to site settings
    Then I should see "add account"
    And I should see "SEO settings"
    And I should see "Access points"
    And I should not see the role dropdown on myself
    And I should see the role dropdown on the "designer"
    And I should see the role dropdown on the "author"
    And I should not see delete on myself
    And I should see delete on the "designer"
    And I should see delete on the "author"

  @javascript
  Scenario: Accessing site settings as a Designer
    Given I am an authenticated "designer"
    When I go to site settings
    Then I should not see "add account"
    And I should see "SEO settings"
    And I should see "Access points"
    And I should not see the role dropdown on myself
    And I should not see the role dropdown on the "admin"
    And I should see the role dropdown on the "author" without the "Administrator" option
    And I should not see delete on the "admin"
    And I should not see delete on myself
    And I should see delete on the "author"

  @javascript
  Scenario: Accessing site settings as an Author
    Given I am an authenticated "author"
    When I go to site settings
    Then I should not see "add account"
    And I should see "SEO settings"
    And I should not see "Access points"
    And I should not see "Accounts"
    # Paranoid Checks
    And I should not see any role dropdowns
    And I should not see any delete buttons
