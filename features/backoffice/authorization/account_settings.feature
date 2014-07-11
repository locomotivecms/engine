Feature: Account Settings
  In order to ensure sites are not tampered with
  As an admin, designer or author
  I will be restricted based on my role

Background:
  Given I have the site: "test site" set up
  And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to account settings
    Then I should see "Log in"

  Scenario: Accessing site settings as an Admin
    Given I am an authenticated "admin"
    When I go to account settings
    Then I should see "new site"

  Scenario: Accessing site settings as a Designer
    Given I am an authenticated "designer"
    When I go to account settings
    Then I should not see "new site"

  Scenario: Accessing site settings as an Author
    Given I am an authenticated "author"
    When I go to account settings
    Then I should not see "new site"
