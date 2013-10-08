Feature: Specific tests to avoid bug regressions

@javascript
Scenario: Changing a field requiredness when the first field is a file (WTF)
  Given I have the site: "test site" set up
  And I have a custom model named "Projects" with
    | label       | type        | required    | target  |
    | Image       | file        | true        |         |
    | Description | string      | true        |         |
  And I am an authenticated user
  Given I go to the list of "Projects"
  And I follow "new entry" within the main content
  Then I should see "Description*"
  Given I go to the "Projects" model edition page
  And I click on the 2nd required flag
  And I press "Save"
  And I wait 100ms
  When I follow "new entry" within the main content
  Then I should not see "Description*"