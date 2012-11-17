Feature: Edit the different properties of a content type

Background:
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | type        | required    | target  |
    | Name        | string      | true        |         |
    | Description | text        | false       |         |
  And I have entries for "Projects" with
    | name              | description                    |
    | Fun project       | Description for the fun one    |
    | Boring project    | Description for the boring one |
  And I am an authenticated user

@javascript
Scenario: I remove all notified accounts
  Given I enable the public submission of the "Projects" model
  When I go to the "Projects" model edition page
  And I unselect the notified accounts
  Then there should not be any notified accounts on the "Projects" model