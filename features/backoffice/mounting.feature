Feature: Mounting Locomotive CMS
  As an administrator
  In order to gain some flexibility when mounting locomotive CMS
  I want to be able to mount locomotove on any given path

  Background:
    Given I have a site set up

  @javascript
  Scenario: Accessing the backend when mounted on a custom path
    Given the engine is mounted on a non standard path
    And I am an authenticated "admin"
    Then I should be able to access the backend
