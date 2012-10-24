Feature: Translations
  In order to avoid template duplication
  As a designer
  I want to be able to define translations and use them in my templates
  
Background:
  Given I have the site: "test site" set up with name: "test site"
  And the site "test site" has locales "en, es"
  And I have a designer and an author
  
  Scenario: As an unauthenticated user
    Given I am not authenticated
    When I go to translations
    Then I should see "Log in"
  
  Scenario: As a designer
    Given I am an authenticated "designer"
    And I go to translations
    And I follow "New translation"
    And I fill in "Key" with "hello_world"
    And I fill in "English" with "Hello, World!"
    And I fill in "Spanish" with "¡Hola, Mundo!"
    And I press "Create"
    Then I should see "Translation was successfully created"
    When I follow "Contents"
    And I follow "Home page"
    And I fill in "page_raw_template" with "{{ 'hello_world' | translate}} {% locale_switcher %}"
    And I press "Save"
    And I follow "See website"
    Then I should see "Hello, World!"
    When I follow "es"
    Then I should see "¡Hola, Mundo!"
    
  Scenario: As an author
    When I am an authenticated "author"
    And I go to translations
    And I follow "New translation"
    And I fill in "Key" with "example_key"
    And I fill in "English" with "Example text"
    And I fill in "Spanish" with "Texto de ejemplo"
    And I press "Create"
    Then I should see "Translation was successfully created"