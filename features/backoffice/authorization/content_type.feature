Feature: Editing a content type
  In order to edit a content type
  As an admin, designer, or author
  I will be restricted based on my role

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | type      | required        |
    | Name        | string    | true            |
    | Description | text      | false           |
  And I have a designer and an author

  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to the "Projects" model edition page
    Then I should see "Log in"

  Scenario: Accessing edition functionality as an Admin
    Given I am an authenticated "admin"
    When I go to the "Projects" model edition page
    Then I should see "Editing model"
    And I should see "Custom fields"

  Scenario: Accessing edition functionality as a Designer
    Given I am an authenticated "designer"
    When I go to the "Projects" model edition page
    Then I should see "Editing model"
    And I should see "Custom fields"

  Scenario: Accessing edition functionality as an Author
    Given I am an authenticated "author"
    When I go to the "Projects" model edition page
    Then I should be on the pages list
    And I should see the access denied message
